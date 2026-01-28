//
//  MarkdownWrapper.h
//  MarkDownAppDemo
//
//  Created by wheat on 1/27/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MarkdownBridge : NSObject

// 改名为 parseMarkdown，这样 Swift 调用时就是 parseMarkdown(_:)
// 不会出现 convert(toHtml:) 这种奇怪的自动重命名
- (NSString *)parseMarkdown:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
