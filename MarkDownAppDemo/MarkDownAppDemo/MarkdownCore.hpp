//
//  MarkdownCore.hpp
//  MarkDownAppDemo
//
//  Created by wheat on 1/27/26.
//

#ifndef MarkdownCore_hpp
#define MarkdownCore_hpp

#include <string>

class MarkdownCore {
public:
    MarkdownCore();
    ~MarkdownCore();
    
    // 核心功能：把 Markdown 字符串转成 HTML 字符串
    std::string processMarkdown(const std::string& input);
};

#endif /* MarkdownCore_hpp */
