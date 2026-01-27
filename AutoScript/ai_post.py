import datetime
import argparse
import subprocess
import json
import os
import re
import hashlib
import time
import requests
import openai
from pathlib import Path

# =========================
# 配置部分
# =========================
API_KEY = os.getenv("AI_POST_KEY", "sk-BIMlxWA1ksae6qASYOBDFlW1e4xByrALU9DHOHevCOyAeuyJ")
OPENAI_BASE_URL = os.getenv("OPENAI_BASE_URL", "https://x666.me/v1")
GEMINI_BASE_URL = os.getenv("GEMINI_BASE_URL", "https://x666.me")

DEFAULT_MODEL = "gemini-2.5-pro-1m"
DEFAULT_GROUP = "level3"

# =========================
# 工具函数
# =========================

def extract_json_block(text: str) -> dict:
    """提取 JSON，忽略末尾可能附加的完成标记"""
    text = text.strip()
    
    # 移除可能存在的完成标记
    text = re.sub(r"<!--.*?-->", "", text, flags=re.DOTALL).strip()

    if "```" in text:
        match = re.search(r"```(?:json)?\s*(\{.*?\})\s*```", text, re.DOTALL)
        if match:
            text = match.group(1)

    if not text.startswith("{"):
        match = re.search(r"\{.*\}", text, re.DOTALL)
        if match:
            text = match.group(0)

    try:
        text = text.replace("，", ",").replace("：", ":").replace("“", '"').replace("”", '"')
        return json.loads(text)
    except json.JSONDecodeError:
        print(f"⚠️ JSON 解析失败，原始内容摘要:\n{text[:200]}...\n")
        return {}

def make_slug(title: str) -> str:
    slug = title.strip()
    slug = re.sub(r"[^\w\u4e00-\u9fa5-]", "-", slug)
    slug = re.sub(r"-+", "-", slug).strip("-")
    if not slug:
        slug = hashlib.md5(title.encode("utf-8")).hexdigest()[:8]
    return slug

def generate_front_matter(title, date, tags=None, draft=False):
    tags = tags or []
    lines = [
        "---",
        f'title: "{title}"',
        f"date: {date.isoformat()}",
        f"draft: {str(draft).lower()}",
    ]
    if tags:
        lines.append("tags:")
        for t in tags:
            lines.append(f"  - {t}")
    lines.append("---")
    return "\n".join(lines) + "\n\n"

# =========================
# 核心：多模型调用路由 (含 HTML 过滤与截断检测)
# =========================

def call_llm(client, model, group, messages, temperature=0.7, max_retries=3):
    """
    增强版调用接口：
    1. 屏蔽 HTML 错误刷屏
    2. 检测 finish_reason 并追加状态标记
    """
    
    for attempt in range(max_retries):
        try:
            content = ""
            is_truncated = False
            finish_reason = "unknown"

            # ===== Gemini 分支 =====
            if model.startswith("gemini-"):
                url = f"{GEMINI_BASE_URL}/v1beta/models/{model}:generateContent"
                headers = {
                    "Content-Type": "application/json",
                    "x-goog-api-key": API_KEY,
                    "Authorization": f"Bearer {API_KEY}"
                }
                
                gemini_contents = []
                for m in messages:
                    role = "model" if m["role"] == "assistant" else "user"
                    gemini_contents.append({
                        "role": role,
                        "parts": [{"text": m["content"]}]
                    })

                payload = {
                    "contents": gemini_contents,
                    "generationConfig": {
                        "temperature": temperature,
                        "maxOutputTokens": 8192
                    }
                }

                resp = requests.post(url, headers=headers, json=payload, timeout=60)
                resp.raise_for_status()
                data = resp.json()
                
                # Gemini 解析
                candidate = data["candidates"][0]
                content = candidate["content"]["parts"][0]["text"]
                finish_reason = candidate.get("finishReason", "UNKNOWN")
                
                # Gemini 的截断标记通常是 "MAX_TOKENS"
                if finish_reason == "MAX_TOKENS":
                    is_truncated = True

            # ===== OpenAI / Claude 分支 =====
            else:
                response = client.chat.completions.create(
                    model=model,
                    messages=messages,
                    temperature=temperature,
                    extra_body={"group": group}
                )

                # 兼容性提取
                if hasattr(response, 'choices'):
                    choice = response.choices[0]
                    content = choice.message.content
                    finish_reason = choice.finish_reason
                elif isinstance(response, dict):
                    choice = response["choices"][0]
                    content = choice["message"]["content"]
                    finish_reason = choice.get("finish_reason")
                else:
                    choice = response["choices"][0]
                    content = choice["message"]["content"]
                    finish_reason = "unknown"

                # OpenAI 的截断标记通常是 "length"
                if finish_reason == "length":
                    is_truncated = True

            # ===== 结果处理：追加标记 =====
            if is_truncated:
                print(f"⚠️  警告：内容可能被截断 (Reason: {finish_reason})")
                content += "\n\n<!-- ⚠️ WARNING: CONTENT TRUNCATED (Max Tokens Reached) -->"
            else:
                # 只有非 JSON 请求（也就是正文生成）才加这个标记，避免破坏 JSON 结构
                # 通过简单判断内容是否像 JSON 来决定
                if not content.strip().startswith("{"):
                    content += "\n\n<!-- ✅ AI GENERATION COMPLETE -->"

            return content

        except Exception as e:
            error_msg = str(e)
            # 🛑 核心修复：检测是否是 HTML 错误页
            if "<!DOCTYPE html>" in error_msg or "<html" in error_msg:
                clean_error = "Server returned HTML error page (Likely 502 Bad Gateway or 404 Not Found)"
            else:
                clean_error = error_msg[:200] + "..." if len(error_msg) > 200 else error_msg

            print(f"❌ 调用失败 (第 {attempt + 1}/{max_retries} 次): {clean_error}")
            
            if attempt < max_retries - 1:
                time.sleep(2)
            else:
                # 最后一次失败，返回空或抛出，这里选择抛出让主程序停止
                raise Exception(clean_error)

# =========================
# AI 逻辑
# =========================

def generate_metadata(draft_text, client, model, group):
    print("🤖 正在生成标题和标签...")
    prompt = (
        "基于以下文章初稿，生成一个吸引人的中文标题和 3-5 个相关标签。\n"
        "请严格只输出 JSON 格式，不要包含任何其他解释文本：\n"
        "{\"title\": \"你的标题\", \"tags\": [\"标签1\", \"标签2\"]}\n\n"
        f"文章内容摘要：{draft_text[:2000]}"
    )

    try:
        content = call_llm(
            client, model, group,
            messages=[{"role": "user", "content": prompt}]
        )
        data = extract_json_block(content)
        title = data.get("title", "未命名文章")
        tags = data.get("tags", [])
        print(f"✅ 标题：{title}")
        return title, tags
    except Exception:
        print("⚠️ 无法生成元数据，使用默认值。")
        return "未命名文章", []

def optimize_with_ai(draft_text, title, client, model, group):
    print("✍️ 正在润色正文 (智能分析文风与逻辑)...")
    
    system_prompt = (
        "你是一位**全能型的资深主编**，拥有极高的文学素养和百科全书般的知识储备。\n"
        "你的核心能力是：**精准捕捉作者意图，在不改变原文风格的前提下，提升文章质量。**\n\n"
        "请严格执行以下处理流程：\n\n"
        "1. 【风格识别与保持 (最高优先级)】：\n"
        "   - 先分析原文的语调（是犀利吐槽、感性日记、严谨技术，还是轻松随笔？）。\n"
        "   - **必须保持这种语调**。如果作者在吐槽，请让吐槽更精准；如果作者很感性，请保留情绪波动。\n"
        "   - ❌ 严禁将文章改写成“AI味”十足的公文或教科书（拒绝滥用“总而言之”、“综上所述”）。\n"
        "   - ✅ 保留作者的个人口头禅或独特的结尾方式（如“不想写了”、“吃饭去”）。\n\n"
        "2. 【事实与逻辑“手术”】：\n"
        "   - **事实核查**：检测文中涉及的历史时间线、专业术语、技术参数或名人名言。发现错误（如时间倒置、概念混淆）必须无声修正。\n"
        "   - **逻辑缝合**：如果文中存在思维跳跃，请在保留原意基础上，用自然的过渡句将其串联，使逻辑链条闭环。\n\n"
        "3. 【针对性优化策略】：\n"
        "   - **若是观点/评论文**：强化论据的力度，确保因果关系成立。\n"
        "   - **若是叙事/日记**：增强画面感和代入感，理顺时间线。\n"
        "   - **若是技术/说明文**：确保步骤准确，术语规范，语言简洁。\n\n"
        "4. 【输出规范】：\n"
        "   - 输出纯正文 Markdown，不带标题，不带 Front Matter。\n"
        f"参考标题：{title}"
    )

    try:
        content = call_llm(
            client, model, group,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": f"请润色这篇草稿：\n\n{draft_text}"}
            ]
        )
        return content.strip()
    except Exception:
        print("❌ 正文生成失败，保留原文。")
        return draft_text + "\n\n<!-- ❌ AI GENERATION FAILED -->"
# =========================
# 主流程
# =========================

def main():
    parser = argparse.ArgumentParser(description="AI 博客自动发布工具")
    parser.add_argument("draft_file", help="草稿文件路径")
    parser.add_argument("--draft", action="store_true", help="标记为草稿")
    parser.add_argument("--output_dir", default="content/posts", help="输出目录")
    parser.add_argument("--model", default=DEFAULT_MODEL, help="使用的模型")
    parser.add_argument("--group", default=DEFAULT_GROUP, help="API 分组")
    parser.add_argument("--no-git", action="store_true", help="跳过 Git 操作")
    args = parser.parse_args()

    client = openai.OpenAI(
        api_key=API_KEY,
        base_url=OPENAI_BASE_URL
    )

    draft_path = Path(args.draft_file)
    if not draft_path.exists():
        print(f"❌ 错误：找不到文件 {args.draft_file}")
        return

    with open(draft_path, "r", encoding="utf-8") as f:
        draft_text = f.read()

    # 1. 生成元数据
    title, tags = generate_metadata(draft_text, client, args.model, args.group)
    
    # 2. 润色正文
    body = optimize_with_ai(draft_text, title, client, args.model, args.group)

    # 3. 组合内容
    now = datetime.datetime.now().astimezone()
    final_content = generate_front_matter(title, now, tags, args.draft) + body

    # 4. 写入文件
    filename = f"{now.date()}-{make_slug(title)}.md"
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    filepath = output_dir / filename
    
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(final_content)
    
    print(f"💾 文件已保存至：{filepath}")

    # 5. Git 操作
    if not args.no_git:
        print("🚀 正在执行 Git 推送...")
        try:
            subprocess.run(["git", "add", str(filepath)], check=True, capture_output=True)
            subprocess.run(["git", "commit", "-m", f"Add post: {title}"], check=True, capture_output=True)
            subprocess.run(["git", "push"], check=True, capture_output=True)
            print("✅ Git 推送成功！")
        except subprocess.CalledProcessError as e:
            print("❌ Git 操作失败！")
            # 同样防止 git 报错刷屏太长，只截取 stderr
            err_msg = e.stderr.decode('utf-8', errors='ignore')
            print(f"错误详情：{err_msg[:300]}...")

if __name__ == "__main__":
    main()