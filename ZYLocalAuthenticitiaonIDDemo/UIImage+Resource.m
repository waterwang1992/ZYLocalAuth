//
//  UIImage+Resource.m
//  ZYLocalAuthenticitiaonIDDemo
//
//  Created by Clarence on 2018/5/17.
//  Copyright © 2018年 Clarence. All rights reserved.
//

#import "UIImage+Resource.h"

@implementation UIImage (Resource)

+ (UIImage *)resourceImageNamed:(NSString *)name{
    //先从默认目录里读
    UIImage *imageFromMainBundle = [UIImage imageNamed:name];
    if (imageFromMainBundle) {
        return imageFromMainBundle;
    }
    //读不到再去Bundle里读
    //此处Scale是判断图片是@2x还是@3x
    NSInteger scale = (NSInteger)[[UIScreen mainScreen] scale];
    for (NSInteger i = scale; i >= 1; i--) {
        NSString *filepath = [self getImagePath:name scale:i];
        UIImage *tempImage = [UIImage imageWithContentsOfFile:filepath];
        if (tempImage) {
            return tempImage;
        }
    }
    return nil;
}

+ (NSString *)getImagePath:(NSString *)name scale:(NSInteger)scale{
    NSURL *bundleUrl = [[NSBundle mainBundle] URLForResource:@"TestBundle" withExtension:@"bundle"];
    NSBundle *customBundle = [NSBundle bundleWithURL:bundleUrl];
    NSString *bundlePath = [customBundle bundlePath];
    NSString *imgPath = [bundlePath stringByAppendingPathComponent:name];
    NSString *pathExtension = [imgPath pathExtension];
    //没有后缀加上PNG后缀
    if (!pathExtension || pathExtension.length == 0) {
        pathExtension = @"png";
    }
    //Scale是根据屏幕不同选择使用@2x还是@3x的图片
    NSString *imageName = nil;
    if (scale == 1) {
        imageName = [NSString stringWithFormat:@"%@.%@", [[imgPath lastPathComponent] stringByDeletingPathExtension], pathExtension];
    }
    else {
        imageName = [NSString stringWithFormat:@"%@@%ldx.%@", [[imgPath lastPathComponent] stringByDeletingPathExtension], (long)scale, pathExtension];
    }
    //返回删掉旧名称加上新名称的路径
    return [[imgPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:imageName];
}
@end
