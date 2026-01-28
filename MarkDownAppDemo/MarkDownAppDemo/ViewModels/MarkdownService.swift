import Foundation
import Down // 引入刚才安装的库

class MarkdownService {
    
    // 渲染 HTML
    func render(_ markdown: String) -> String {
        do {
            // 1. 使用 Down 库将 Markdown 转换为 HTML 片段
            // Down 自动处理了 标题、列表、粗体、引用、甚至是表格
            let down = Down(markdownString: markdown)
            let bodyHtml = try down.toHTML()
            
            // 2. 包装成完整的 HTML 页面
            return wrapToHtmlPage(bodyContent: bodyHtml)
        } catch {
            return "<p>Error parsing markdown: \(error)</p>"
        }
    }
    
    private func wrapToHtmlPage(bodyContent: String) -> String {
        // 这里集成了：GitHub CSS + KaTeX + Highlight.js
        return """
        <!DOCTYPE html>
        <html lang="zh">
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            
            <!-- 1. GitHub Markdown CSS -->
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/github-markdown-css@5.5.0/github-markdown.min.css">
            
            <!-- 2. Highlight.js 代码高亮 -->
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark-dimmed.min.css">
            <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
            
            <!-- 3. KaTeX 数学公式 -->
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">
            <script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
            <script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/contrib/auto-render.min.js"></script>

            <style>
                /* 稍微调整一下边距，并且适配深色模式 */
                .markdown-body {
                    box-sizing: border-box;
                    min-width: 200px;
                    max-width: 980px;
                    margin: 0 auto;
                    padding: 45px;
                }
                
                @media (max-width: 767px) {
                    .markdown-body {
                        padding: 15px;
                    }
                }
                
                /* 适配系统深色模式 */
                @media (prefers-color-scheme: dark) {
                    body { background-color: #0d1117; }
                }
                @media (prefers-color-scheme: light) {
                    body { background-color: #ffffff; }
                }
            </style>
        </head>
        <body class="markdown-body">
            <!-- 注入内容 -->
            \(bodyContent)
            
            <script>
                // 1. 触发代码高亮
                hljs.highlightAll();
                
                // 2. 触发数学公式渲染
                document.addEventListener("DOMContentLoaded", function() {
                    renderMathInElement(document.body, {
                        delimiters: [
                            {left: '$$', right: '$$', display: true},
                            {left: '$', right: '$', display: false}
                        ],
                        throwOnError: false
                    });
                });
            </script>
        </body>
        </html>
        """
    }
}