//
//  UIImage+ImageDecoder.m
//  Juny_BitMapDemo
//
//  Created by 宋俊红 on 17/4/7.
//  Copyright © 2017年 Juny_song. All rights reserved.
//参照大神的博客http://blog.leichunfeng.com/blog/2017/02/20/talking-about-the-decompression-of-the-image-in-ios/
/* UIImage *image = [UIImage imageWithContentsOfFile:filePath];或者是从Disk中加载时
 *用这个方法加载图片时，需要在分线程中使用解压缩图片，来加速图片显示
 *现在还有一个小小的疑问，我拿到一个UIImage的图，我怎么知道它是解压缩过的还是未解压缩的
 */
#import "UIImage+ImageDecoder.h"

@implementation UIImage (ImageDecoder)


+ (UIImage *)decodedImageWithImage:(UIImage *)image {
    // while downloading huge amount of images
    // autorelease the bitmap context
    // and all vars to help system to free memory
    // when there are memory warning.
    
    if (image == nil) { // Prevent "CGBitmapContextCreateImage: invalid context 0x0" error
        return nil;
    }
    
    @autoreleasepool{
        // 不解压animationImage
        if (image.images != nil) {
            return image;
        }
        
        CGImageRef imageRef = image.CGImage;
        //获取alpha通道，如果是有alpha通道的，不解压
        CGImageAlphaInfo alpha = CGImageGetAlphaInfo(imageRef);
        BOOL anyAlpha = (alpha == kCGImageAlphaFirst ||
                         alpha == kCGImageAlphaLast ||
                         alpha == kCGImageAlphaPremultipliedFirst ||
                         alpha == kCGImageAlphaPremultipliedLast);
        if (anyAlpha) {
            return image;
        }
        
        // current颜色空间
        CGColorSpaceModel imageColorSpaceModel = CGColorSpaceGetModel(CGImageGetColorSpace(imageRef));//颜色空间模型
        CGColorSpaceRef colorspaceRef = CGImageGetColorSpace(imageRef);//颜色空间具体表达
        
        BOOL unsupportedColorSpace = (imageColorSpaceModel == kCGColorSpaceModelUnknown ||
                                      imageColorSpaceModel == kCGColorSpaceModelMonochrome ||
                                      imageColorSpaceModel == kCGColorSpaceModelCMYK ||
                                      imageColorSpaceModel == kCGColorSpaceModelIndexed);
        if (unsupportedColorSpace) {//如果是不支持的颜色空间，那么把颜色空间强制设置为RGB
            colorspaceRef = CGColorSpaceCreateDeviceRGB();
        }
        
        size_t width = CGImageGetWidth(imageRef);//位图的像素宽度
        size_t height = CGImageGetHeight(imageRef);//位图的像素高度
//        NSUInteger bytesPerPixel = 4;//每个像素的字节数
        NSUInteger bytesPerRow = 0;//bytesPerPixel * width为途中每一行使用的字节数，指定为0时，系统可自动计算，并且优化
        NSUInteger bitsPerComponent = 8;//一个像素中每个独立的颜色分量使用的bit数
        /*
         CGBitmapContextCreate(<#void * _Nullable data#>, <#size_t width#>, <#size_t height#>, <#size_t bitsPerComponent#>, <#size_t bytesPerRow#>, <#CGColorSpaceRef  _Nullable space#>, <#uint32_t bitmapInfo#>)
         Pixel Format像素格式
         Bits per component ：一个像素中每个独立的颜色分量使用的 bit 数；
         Bits per pixel ：一个像素使用的总 bit 数；
         Bytes per row ：位图中的每一行使用的字节数
         
         Color and Color Spaces颜色和颜色空间，也就是颜色数值表示的定义
          当图片不包含 alpha 的时候使用 kCGImageAlphaNoneSkipFirst ，否则使用 kCGImageAlphaPremultipliedFirst 。
         Color Spaces and Bitmap Layout颜色空间和位图布局
         data：如果不为 NULL ，那么它应该指向一块大小至少为 bytesPerRow * height 字节的内存；如果 为 NULL ，那么系统就会为我们自动分配和释放所需的内存，所以一般指定 NULL 即可
         width 和 height ：位图的宽度和高度，分别赋值为图片的像素宽度和像素高度即可
         bitsPerComponent ：像素的每个颜色分量使用的 bit 数，在 RGB 颜色空间下指定 8 即可；
         bytesPerRow ：位图的每一行使用的字节数，大小至少为 width * bytes per pixel 字节。有意思的是，当我们指定 0 时，系统不仅会为我们自动计算，而且还会进行 cache line alignment 的优化
         space ：就是我们前面提到的颜色空间，一般使用 RGB 即可；
         bitmapInfo ：就是我们前面提到的位图的布局信息。
         */
        
        // kCGImageAlphaNone is not supported in CGBitmapContextCreate.
        // Since the original image here has no alpha info, use kCGImageAlphaNoneSkipLast
        // to create bitmap graphics contexts without alpha info.
        //创建位图上下文
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     width,
                                                     height,
                                                     bitsPerComponent,
                                                     bytesPerRow,
                                                     colorspaceRef,
                                                     kCGBitmapByteOrderDefault|kCGImageAlphaNoneSkipLast);
        
        // Draw the image into the context and retrieve the new bitmap image without alpha
        //为什么说新建的位图是解压缩后的位图，我的理解是，把原始未解压缩位图根据信息绘制到上下中，所以上下文中的位图应该是未压缩的也就是解压缩过的，然后再从上下文中创建位图，此时的位图必然是原始的，未压缩的，需要渲染到UImageView的图层上的
        //将原始位图，绘制到上下文中
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        //创建一个新的解压后的位图
        CGImageRef imageRefWithoutAlpha = CGBitmapContextCreateImage(context);
        //创建一个UIImage对象返回
        UIImage *imageWithoutAlpha = [UIImage imageWithCGImage:imageRefWithoutAlpha
                                                         scale:image.scale
                                                   orientation:image.imageOrientation];
        //如果不是支持的颜色空间，需要释放颜色空间，因为之前创建了
        if (unsupportedColorSpace) {
            CGColorSpaceRelease(colorspaceRef);
        }
        //释放位图上下文和无alpha通道的位图，这些都是通过create函数创建的
        CGContextRelease(context);
        CGImageRelease(imageRefWithoutAlpha);
        
        return imageWithoutAlpha;
    }
}
@end
