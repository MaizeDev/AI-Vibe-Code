//
//  MarkdownWrapper.m
//  MarkDownAppDemo
//
//  Created by wheat on 1/27/26.
//

#import "MarkdownBridge.h"
#import "MarkdownCore.hpp"

@implementation MarkdownBridge {
    MarkdownCore *_core;
}

- (instancetype)init {
    self = [super init];
    if (self) _core = MarkdownCore();
    return self;
}

- (NSString *)convertToHtml:(NSString *)markdown {
    if (!markdown) return @"";
    std::string cppInput = [markdown UTF8String];
    std::string cppOutput = _core.parseToHtml(cppInput);
    return [NSString stringWithUTF8String:cppOutput.c_str()];
}
@end
