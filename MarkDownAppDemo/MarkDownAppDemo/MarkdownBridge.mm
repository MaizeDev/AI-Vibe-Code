//
//  MarkdownWrapper.m
//  MarkDownAppDemo
//
//  Created by wheat on 1/27/26.
//

#import "MarkdownBridge.h"
#import "MarkdownCore.hpp"

@implementation MarkdownBridge {
    // 定义为 C++ 对象的指针
    MarkdownCore *_core;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 修正 1: 使用 'new' 在堆上分配内存
        _core = new MarkdownCore();
    }
    return self;
}

// 必须手动释放 C++ 内存，否则会内存泄漏
- (void)dealloc {
    delete _core;
}

- (NSString *)parseMarkdown:(NSString *)text { // 我改了个名字，防止 Swift 乱改名
    if (!text) return @"";
    
    std::string cppInput = [text UTF8String];
    
    // 修正 2: 指针调用方法必须用 '->' 而不是 '.'
    std::string cppOutput = _core->processMarkdown(cppInput);
    
    return [NSString stringWithUTF8String:cppOutput.c_str()];
}

@end
