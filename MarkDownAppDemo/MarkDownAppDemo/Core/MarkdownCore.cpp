#include "MarkdownCore.hpp"
#include <sstream>
#include <regex>
#include <vector>
#include <string>

MarkdownCore::MarkdownCore() {}
MarkdownCore::~MarkdownCore() {}

// 字符串替换
void replaceAll(std::string& str, const std::string& from, const std::string& to) {
    if(from.empty()) return;
    size_t start_pos = 0;
    while((start_pos = str.find(from, start_pos)) != std::string::npos) {
        str.replace(start_pos, from.length(), to);
        start_pos += to.length();
    }
}

// HTML 转义 (保护 < > &)
std::string escapeHtml(const std::string& data) {
    std::string buffer;
    buffer.reserve(data.size());
    for(size_t pos = 0; pos != data.size(); ++pos) {
        switch(data[pos]) {
            case '&':  buffer.append("&amp;");       break;
            case '\"': buffer.append("&quot;");      break;
            case '\'': buffer.append("&apos;");      break;
            case '<':  buffer.append("&lt;");        break;
            case '>':  buffer.append("&gt;");        break;
            default:   buffer.append(&data[pos], 1); break;
        }
    }
    return buffer;
}

std::string MarkdownCore::processMarkdown(const std::string& input) {
    std::string text = input;
    std::vector<std::string> mathBlocks;
    std::vector<std::string> codeBlocks;
    
    // --- 1. 保护代码块 (避免代码里的 $$ 被误伤) ---
    std::string placeholderCode = "__CODE_BLOCK_";
    size_t pos = 0;
    while ((pos = text.find("```", pos)) != std::string::npos) {
        size_t end = text.find("```", pos + 3);
        if (end != std::string::npos) {
            std::string raw = text.substr(pos + 3, end - pos - 3);
            // 虽然是保护，但顺便把它格式化成 HTML
            std::string content = "<pre><code>" + escapeHtml(raw) + "</code></pre>";
            codeBlocks.push_back(content);
            std::string key = placeholderCode + std::to_string(codeBlocks.size() - 1) + "__";
            text.replace(pos, end - pos + 3, key);
            pos += key.length();
        } else { break; }
    }
    
    // --- 2. 保护数学公式 (这是关键！) ---
    // 我们只负责提取，不转义，也不加 <script>，原样放回去给 KaTeX 识别
    std::string placeholderMath = "__MATH_BLOCK_";
    pos = 0;
    while ((pos = text.find("$$", pos)) != std::string::npos) {
        size_t end = text.find("$$", pos + 2);
        if (end != std::string::npos) {
            std::string content = text.substr(pos, end - pos + 2);
            mathBlocks.push_back(content);
            std::string key = placeholderMath + std::to_string(mathBlocks.size() - 1) + "__";
            text.replace(pos, end - pos + 2, key);
            pos += key.length();
        } else { break; }
    }
    
    // --- 3. 常规 Markdown 解析 ---
    std::stringstream ss(text);
    std::string line;
    std::string bodyContent;
    
    while (std::getline(ss, line)) {
        // 遇到占位符直接放行，不要包 <p>
        if (line.find("__MATH_BLOCK_") != std::string::npos ||
            line.find("__CODE_BLOCK_") != std::string::npos) {
            bodyContent += line + "\n";
            continue;
        }
        
        std::string processed = escapeHtml(line);
        
        if (processed.find("# ") == 0) processed = "<h1>" + processed.substr(2) + "</h1>";
        else if (processed.find("## ") == 0) processed = "<h2>" + processed.substr(3) + "</h2>";
        else if (processed.find("### ") == 0) processed = "<h3>" + processed.substr(4) + "</h3>";
        else if (processed.find("- ") == 0) processed = "<li>" + processed.substr(2) + "</li>";
        else if (std::regex_match(line, std::regex("^\\d+\\.\\s+.*"))) processed = "<li>" + processed + "</li>";
        else if (!processed.empty()) processed = "<p>" + processed + "</p>";
        
        // 行内样式
        processed = std::regex_replace(processed, std::regex("\\*\\*(.*?)\\*\\*"), "<strong>$1</strong>");
        processed = std::regex_replace(processed, std::regex("`(.*?)`"), "<code>$1</code>");
        processed = std::regex_replace(processed, std::regex("\\[(.*?)\\]\\((.*?)\\)"), "<a href='$2'>$1</a>");
        
        bodyContent += processed + "\n";
    }
    
    // --- 4. 恢复内容 ---
    for (size_t i = 0; i < mathBlocks.size(); ++i) {
        std::string key = placeholderMath + std::to_string(i) + "__";
        // 注意：这里恢复的是原始的 $$...$$ 字符串
        replaceAll(bodyContent, key, mathBlocks[i]);
    }
    for (size_t i = 0; i < codeBlocks.size(); ++i) {
        std::string key = placeholderCode + std::to_string(i) + "__";
        replaceAll(bodyContent, key, codeBlocks[i]);
    }
    
    // 关键改变：只返回 Body 内容，不返回 <html>
    return bodyContent;
}
