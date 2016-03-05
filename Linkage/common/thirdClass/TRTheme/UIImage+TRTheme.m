//
//  UIImage+TRTheme.m
//  YGTravel
//
//  Created by Mac mini on 16/1/11.
//  Copyright © 2016年 ygsoft. All rights reserved.
//

#import "UIImage+TRTheme.h"
#import "TRThemeManager.h"
#import <objc/runtime.h>

@implementation NSObject (TRTheme)

+ (void)exchangeInstanceMethod1:(SEL)method1 method2:(SEL)method2
{
    method_exchangeImplementations(class_getInstanceMethod(self, method1), class_getInstanceMethod(self, method2));
}

+ (void)exchangeClassMethod1:(SEL)method1 method2:(SEL)method2
{
    method_exchangeImplementations(class_getClassMethod(self, method1), class_getClassMethod(self, method2));
}

@end

@implementation UIImage (TRTheme)
+ (UIImage *)tr_imageNamed:(NSString *)name
{
    NSRange range = [name rangeOfString:@"."];
    NSString *typeExt = range.location == NSNotFound? @"png": nil;
    NSBundle *bundle = [TRThemeManager shareInstance].themeBundle;
    NSString *path = [bundle pathForResource:name ofType:typeExt];
    if (!path) {
        NSString *retinaName = [NSString stringWithFormat:@"%@@2x", name];
        path = [bundle pathForResource:retinaName ofType:typeExt];
    }
    return [self imageWithData:[NSData dataWithContentsOfFile:path]
                  scale:isRetinaFilePath(path) ? 2.0f : 1.0f];
}

inline static BOOL isRetinaFilePath(NSString *path)
{
    NSRange retinaSuffixRange = [[path lastPathComponent] rangeOfString:@"@2x" options:NSCaseInsensitiveSearch];
    return retinaSuffixRange.length && retinaSuffixRange.location != NSNotFound;
}

@end