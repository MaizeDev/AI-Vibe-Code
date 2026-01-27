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

DEFAULT_MODEL = "gpt-4o-mini"
DEFAULT_GROUP = "level3"

# =========================
# 工具函数
# =========================

def extract_json_block(text: str) -> dict:
    """提取 JSON"""
    text = text.strip()
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
        print(f"⚠️ 标题元数据解析失败，使用默认值。")
        return {}

def make_slug(title: str) -> str:
    """文件名安全处理"""
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
# AI 接口调用 (仅用于生成标题/标签)
# =========================

def call_llm_metadata(client, model, group, prompt):
    """
    仅用于获取元数据的简单调用
    """
    messages = [{"role": "user", "content": prompt}]
    
    try:
        # Gemini 分支
        if model.startswith("gemini-"):
            url = f"{GEMINI_BASE_URL}/v1beta/models/{model}:generateContent"
            headers = {
                "Content-Type": "application/json",
                "x-goog-api-key": API_KEY,
                "Authorization": f"Bearer {API_KEY}"
            }
            gemini_contents = [{"role": "user", "parts": [{"text": prompt}]}]
            payload = {"contents": gemini_contents}
            
            resp = requests.post(url, headers=headers, json=payload, timeout=30)
            resp.raise_for_status()
            data = resp.json()
            return data["candidates"][0]["content"]["parts"][0]["text"]

        # OpenAI / Claude 分支
        else:
            response = client.chat.completions.create(
                model=model,
                messages=messages,
                temperature=0.7,
                extra_body={"group": group}
            )
            if hasattr(response, 'choices'):
                return response.choices[0].message.content
            return response["choices"][0]["message"]["content"]

    except Exception as e:
        print(f"⚠️ AI 接口调用出错: {e}")
        return "{}"

# =========================
# 核心逻辑
# =========================

def generate_metadata(draft_text, client, model, group):
    print("🤖 正在分析内容并生成标题/标签...")
    prompt = (
        "阅读以下文章内容，提取一个精炼的中文标题和 3-5 个标签。\n"
        "严格只输出 JSON 格式：\n"
        "{\"title\": \"文章标题\", \"tags\": [\"标签1\", \"标签2\"]}\n\n"
        f"内容摘要：{draft_text[:1500]}"
    )

    content = call_llm_metadata(client, model, group, prompt)
    data = extract_json_block(content)
    
    title = data.get("title", "未命名文章")
    tags = data.get("tags", [])
    
    # 如果 AI 失败，尝试用第一行做标题
    if title == "未命名文章":
        first_line = draft_text.strip().split('\n')[0]
        if len(first_line) < 50:
            title = first_line
            
    print(f"✅ 标题：{title}")
    return title, tags

# =========================
# 主流程
# =========================

def main():
    parser = argparse.ArgumentParser(description="博客发布工具 (无内容修改版)")
    parser.add_argument("draft_file", help="草稿文件路径 (.txt, .md)")
    parser.add_argument("--draft", action="store_true", help="标记为草稿")
    parser.add_argument("--output_dir", default="content/posts", help="输出目录")
    parser.add_argument("--model", default=DEFAULT_MODEL, help="用于生成标题的模型")
    parser.add_argument("--group", default=DEFAULT_GROUP, help="API 分组")
    parser.add_argument("--no-git", action="store_true", help="跳过 Git 操作")
    args = parser.parse_args()

    client = openai.OpenAI(api_key=API_KEY, base_url=OPENAI_BASE_URL)
    draft_path = Path(args.draft_file)

    if not draft_path.exists():
        print(f"❌ 错误：找不到文件 {args.draft_file}")
        return

    # 读取原文
    try:
        with open(draft_path, "r", encoding="utf-8") as f:
            draft_text = f.read()
    except UnicodeDecodeError:
        print("❌ 文件编码错误，请确保文件是 UTF-8 格式")
        return

    # 1. 生成元数据 (标题 & 标签)
    title, tags = generate_metadata(draft_text, client, args.model, args.group)
    
    # 2. 格式化内容 (Front Matter + 原文)
    now = datetime.datetime.now().astimezone()
    # 移除原文开头可能存在的旧标题（可选逻辑，防止标题重复）
    # draft_text = draft_text.lstrip() 
    
    final_content = generate_front_matter(title, now, tags, args.draft) + draft_text

    # 3. 写入文件
    filename = f"{now.date()}-{make_slug(title)}.md"
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    filepath = output_dir / filename
    
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(final_content)
    
    print(f"💾 已生成格式化文件：{filepath}")

    # 4. Git 操作
    if not args.no_git:
        print("🚀 正在执行 Git 推送...")
        try:
            subprocess.run(["git", "add", str(filepath)], check=True, capture_output=True)
            subprocess.run(["git", "commit", "-m", f"Post: {title}"], check=True, capture_output=True)
            subprocess.run(["git", "push"], check=True, capture_output=True)
            print("✅ Git 推送成功！")
        except subprocess.CalledProcessError as e:
            print("❌ Git 操作失败！")
            print(f"错误详情：{e.stderr.decode('utf-8', errors='ignore')}")

if __name__ == "__main__":
    main()