#include "MarkdownCore.hpp"
#include <sstream>
#include <regex>
#include <vector>
#include <iostream>

MarkdownCore::MarkdownCore() {}
MarkdownCore::~MarkdownCore() {}

std::string safeRegexReplace(const std::string& input, const std::string& pattern, const std::string& format) {
    try {
        std::regex re(pattern);
        return std::regex_replace(input, re, format);
    } catch (const std::regex_error& e) {
        return input;
    }
}

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
    // 1. 升级 CSS：同时支持 Dark Mode (默认) 和 Light Mode
    std::string css = R"(
        <style>
            :root {
                color-scheme: light dark; /* 告诉 WebView 支持两种模式 */
            }
            body {
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
                font-size: 16px;
                line-height: 1.6;
                padding: 30px;
            }
            /* --- Dark Mode (默认) --- */
            @media (prefers-color-scheme: dark) {
                body { color: #c9d1d9; background-color: #0d1117; }
                h1, h2, h3 { color: #ffffff; border-bottom-color: #21262d; }
                pre { background-color: #161b22; border-color: #30363d; }
                code { background-color: rgba(110,118,129,0.4); color: #ff7b72; }
                blockquote { color: #8b949e; border-left-color: #1f6feb; background-color: rgba(31, 111, 235, 0.1); }
                a { color: #58a6ff; }
                strong { color: #f0f6fc; }
            }
            /* --- Light Mode (白天) --- */
            @media (prefers-color-scheme: light) {
                body { color: #24292f; background-color: #ffffff; }
                h1, h2, h3 { color: #1f2328; border-bottom-color: #d0d7de; }
                pre { background-color: #f6f8fa; border-color: #d0d7de; } /* 浅灰背景 */
                code { background-color: rgba(175, 184, 193, 0.2); color: #cf222e; } /* 红色代码文字 */
                pre code { color: #1f2328; }
                blockquote { color: #57606a; border-left-color: #0969da; background-color: #ddf4ff; }
                a { color: #0969da; }
                strong { color: #24292f; }
            }

            h1 { font-size: 2em; border-bottom-style: solid; border-bottom-width: 1px; padding-bottom: 0.3em; margin-top: 24px; }
            h2 { font-size: 1.5em; border-bottom-style: solid; border-bottom-width: 1px; padding-bottom: 0.3em; margin-top: 24px; }
            
            pre { border-radius: 6px; padding: 16px; overflow: auto; border-style: solid; border-width: 1px; margin-bottom: 16px; }
            pre code { background-color: transparent; padding: 0; font-family: Menlo, Monaco, monospace; }
            code { padding: 0.2em 0.4em; border-radius: 6px; font-family: Menlo, Monaco, monospace; font-size: 85%; }
            blockquote { border-left-width: 0.25em; border-left-style: solid; padding: 0 1em; margin: 0 0 16px 0; }
            
            ul, ol { padding-left: 2em; margin-bottom: 16px; }
            li { margin-bottom: 0.25em; }
            a { text-decoration: none; }
            a:hover { text-decoration: underline; }
            img { max-width: 100%; border-radius: 6px; }
        </style>
    )";

    std::stringstream ss(input);
    std::string line;
    std::string content = "";
    
    // --- 状态机 ---
    bool inCodeBlock = false;
    // 列表状态：0=无, 1=无序列表(ul), 2=有序列表(ol)
    int listState = 0;
    
    while (std::getline(ss, line)) {
        
        // 1. 处理代码块 (优先级最高)
        if (line.find("```") == 0) {
            if (inCodeBlock) {
                content += "</code></pre>\n";
                inCodeBlock = false;
            } else {
                // 如果之前在列表里，先关闭列表
                if (listState == 1) { content += "</ul>\n"; listState = 0; }
                if (listState == 2) { content += "</ol>\n"; listState = 0; }
                
                content += "<pre><code>";
                inCodeBlock = true;
            }
            continue;
        }
        
        if (inCodeBlock) {
            content += escapeHtml(line) + "\n";
            continue;
        }

        // 2. 检测当前行是否是列表
        bool isUl = (line.find("- ") == 0);
        bool isOl = std::regex_match(line, std::regex("^\\d+\\.\\s+.*"));
        
        // --- 列表状态管理 ---
        if (isUl) {
            // 如果原本是 OL，先关掉 OL
            if (listState == 2) { content += "</ol>\n"; listState = 0; }
            // 如果原本没开列表，开启 UL
            if (listState == 0) { content += "<ul>\n"; listState = 1; }
        } else if (isOl) {
            // 如果原本是 UL，先关掉 UL
            if (listState == 1) { content += "</ul>\n"; listState = 0; }
            // 如果原本没开列表，开启 OL
            if (listState == 0) { content += "<ol>\n"; listState = 2; }
        } else {
            // 如果当前行不是列表，但之前开启了列表，赶紧关掉
            if (listState == 1) { content += "</ul>\n"; listState = 0; }
            if (listState == 2) { content += "</ol>\n"; listState = 0; }
        }

        // --- 3. 解析具体内容 ---
        std::string processedLine = line;
        
        if (isUl) {
            // 提取 - 后面的内容
            std::string text = escapeHtml(line.substr(2));
            processedLine = "<li>" + text + "</li>";
        } else if (isOl) {
            // 提取 1. 后面的内容 (用正则去掉开头的数字)
            std::string text = safeRegexReplace(escapeHtml(line), "^\\d+\\.\\s+(.*)", "$1");
            processedLine = "<li>" + text + "</li>";
        } else if (line.find("### ") == 0) {
            processedLine = "<h3>" + escapeHtml(line.substr(4)) + "</h3>";
        } else if (line.find("## ") == 0) {
            processedLine = "<h2>" + escapeHtml(line.substr(3)) + "</h2>";
        } else if (line.find("# ") == 0) {
            processedLine = "<h1>" + escapeHtml(line.substr(2)) + "</h1>";
        } else if (line.find("> ") == 0) {
            processedLine = "<blockquote>" + escapeHtml(line.substr(2)) + "</blockquote>";
        } else {
            // 普通文本
            processedLine = escapeHtml(line);
        }
        
        // --- 4. 行内样式 (在 li 内部也可以加粗) ---
        // 链接
        processedLine = safeRegexReplace(processedLine, "\\[(.*?)\\]\\((.*?)\\)", "<a href='$2'>$1</a>");
        // 图片
        processedLine = safeRegexReplace(processedLine, "!\\[(.*?)\\]\\((.*?)\\)", "<img src='$2' alt='$1'>");
        // 加粗
        processedLine = safeRegexReplace(processedLine, "\\*\\*(.*?)\\*\\*", "<strong>$1</strong>");
        // 代码
        processedLine = safeRegexReplace(processedLine, "`(.*?)`", "<code>$1</code>");

        // --- 5. 组装 ---
        if (isUl || isOl) {
            content += processedLine + "\n";
        } else if (line.find("# ") != 0 && line.find("> ") != 0 && !line.empty()) {
            content += "<p>" + processedLine + "</p>\n";
        } else {
            content += processedLine + "\n";
        }
    }
    
    // 循环结束时，如果还有列表没关，关掉它
    if (listState == 1) content += "</ul>";
    if (listState == 2) content += "</ol>";
    
    return "<html><head>" + css + "</head><body>" + content + "</body></html>";
}
