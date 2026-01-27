//
//  MarkdownWrapper.h
//  MarkDownAppDemo
//
//  Created by wheat on 1/27/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 这个类必须继承自 NSObject，且只能包含 OC 的类型，不能出现 C++ 类型
@interface MarkdownWrapper : NSObject

- (NSString *)parseMarkdown:(NSString *)text;
- (NSInteger)getWordCount:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
