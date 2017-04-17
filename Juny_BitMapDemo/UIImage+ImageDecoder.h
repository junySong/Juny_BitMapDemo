//
//  UIImage+ImageDecoder.h
//  Juny_BitMapDemo
//
//  Created by 宋俊红 on 17/4/7.
//  Copyright © 2017年 Juny_song. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageDecoder)

/**
 解压缩图片（图片解压缩不可避免，我们不想让它在主线程中执行，影响我们的响应性。那我们可以在子线程中对图片强制解压缩）
 强制解压缩的原理就是对图片进行重新绘制，得到一张新的，解压缩后的位图
 @param image 解压前的图片
 @return 解压后的图片
 */
+ (UIImage *)decodedImageWithImage:(UIImage *)image;
@end
