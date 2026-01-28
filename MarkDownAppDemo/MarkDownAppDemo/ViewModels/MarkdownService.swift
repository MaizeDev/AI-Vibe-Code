import Foundation
import Down

class MarkdownService {
    
    func render(_ markdown: String) -> String {
        do {
            // 1. 显式使用默认选项 (包含 GFM 表格、自动链接等支持)
            // DownOptions.default = .smart + .safe + .hardBreaks
            let down = Down(markdownString: markdown)
            // 注意：要确保 Table 渲染，Markdown 上下文很重要，Down 默认支持
            let bodyHtml = try down.toHTML(.default)
            
            return wrapToHtmlPage(bodyContent: bodyHtml)
        } catch {
            return "<p>Error parsing markdown: \(error)</p>"
        }
    }
    
    private func wrapToHtmlPage(bodyContent: String) -> String {
        return """
        <!DOCTYPE html>
        <html lang="zh">
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            
            <!-- 1. GitHub Markdown CSS -->
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/github-markdown-css@5.5.0/github-markdown.min.css">
            
            <!-- 2. Highlight.js (代码高亮 - 使用 GitHub Dark 主题) -->
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark.min.css">
            <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
            
            <!-- 2.1 Highlight.js 行号插件 -->
            <script src="https://cdn.jsdelivr.net/npm/highlightjs-line-numbers.js@2.8.0/dist/highlightjs-line-numbers.min.js"></script>
            
            <!-- 3. KaTeX (数学公式) -->
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">
            <script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
            <script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/contrib/auto-render.min.js"></script>

            <style>
                .markdown-body {
                    box-sizing: border-box;
                    min-width: 200px;
                    max-width: 980px;
                    margin: 0 auto;
                    padding: 45px;
                }
                
                @media (max-width: 767px) {
                    .markdown-body { padding: 15px; }
                }
                
                /* 适配系统深色模式 */
                @media (prefers-color-scheme: dark) {
                    body { background-color: #0d1117; }
                }
                @media (prefers-color-scheme: light) {
                    body { background-color: #ffffff; }
                }
                
                /* ---行号样式定制--- */
                /* 表格修正：强制行号列不准被选中，且颜色变淡 */
                .hljs-ln-numbers {
                    -webkit-user-select: none;
                    text-align: right;
                    border-right: 1px solid #c5c5c5;
                    vertical-align: top;
                    padding-right: 10px !important;
                    color: #888;
                }
                /* 代码内容列 */
                .hljs-ln-code {
                    padding-left: 15px !important;
                }
                /* 调整代码块背景和圆角，像 Typora/GitHub */
                pre code.hljs {
                    padding: 10px;
                    border-radius: 6px;
                }
            </style>
        </head>
        <body class="markdown-body">
            \(bodyContent)
            
            <script>
                // 1. 触发代码高亮
                hljs.highlightAll();
                
                // 2. 触发增加行号 (等待 highlight 完成后)
                hljs.initLineNumbersOnLoad();
                
                // 3. 触发数学公式
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
