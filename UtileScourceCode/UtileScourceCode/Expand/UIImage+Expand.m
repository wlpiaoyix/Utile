//
//  UIImage+Convenience.m
//  AKSL-189-Msp
//
//  Created by AKSL-td on 13-12-3.
//  Copyright (c) 2013年 AKSL. All rights reserved.
//

#import "UIImage+Expand.h"

#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>
#import "qrencode.h"
enum {
    qr_margin = 3
};


const NSString *PYColorMatrixCILinearToSRGBToneCurve = @"CILinearToSRGBToneCurve";
const NSString *PYColorMatrixCIPhotoEffectChrome = @"CIPhotoEffectChrome";
const NSString *PYColorMatrixCIPhotoEffectFade = @"CIPhotoEffectFade";
const NSString *PYColorMatrixCIPhotoEffectInstant = @"CIPhotoEffectInstant";
const NSString *PYColorMatrixCIPhotoEffectMono = @"CIPhotoEffectMono";
const NSString *PYColorMatrixCIPhotoEffectNoir = @"CIPhotoEffectNoir";
const NSString *PYColorMatrixCIPhotoEffectProcess = @"CIPhotoEffectProcess";
const NSString *PYColorMatrixCIPhotoEffectTonal = @"CIPhotoEffectTonal";
const NSString *PYColorMatrixCIPhotoEffectTransfer = @"CIPhotoEffectTransfer";
const NSString *PYColorMatrixCISRGBToneCurveToLinear = @"CISRGBToneCurveToLinear";
const NSString *PYColorMatrixCIVignetteEffect = @"CIVignetteEffect";

@implementation UIImage (Expand)
-(UIImage*) setImageSize:(CGSize) size{
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
-(UIImage*) cutImage:(CGRect) cutValue{
    if(![self isKindOfClass:[UIImage class]]){// like the java's instandOf
        return nil;
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage],cutValue);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return  image;
}
-(UIImage*) cutImageFit:(CGSize) size{
    CGSize temp;
    if (self.size.width/size.width>self.size.height/size.height) {
        temp.height = self.size.height;
        temp.width = self.size.height/size.height*size.width;
    }else{
        temp.width = self.size.width;
        temp.height = self.size.width/size.width*size.height;
    }
    float x = (self.size.width-temp.width)/2;
    float y = (self.size.height-temp.height)/2;
    CGRect r = CGRectMake(x, y, temp.width, temp.height);
    return [self cutImage:r];
}
-(UIImage*) cutImageCenter:(CGSize) size{
    float x = (self.size.width-size.width)/2;
    float y = (self.size.height-size.height)/2;
    CGRect r = CGRectMake(x, y, size.width, size.height);
    return [self cutImage:r];
}
+ (UIImage *)imageWithColor:(UIColor *)color {
    UIImage *image = [self imageWithSize:CGSizeMake(1.0f, 1.0f) color:[color CGColor]];
    return image;
}
+ (UIImage *)imageWithSize:(CGSize) size color:(CGColorRef) colorRef{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, colorRef);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
+ (UIImage *)imageWithSize:(CGSize) size blockDraw:(void (^ _Nonnull) (CGContextRef context, CGRect rect)) blockDraw{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    blockDraw(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/**
 二维码
 */
+(UIImage * _Nonnull) imageWithQRCode:(NSString * _Nonnull) QRCode size:(CGFloat) size{
    if (![QRCode length]) {
        return nil;
    }
    
    QRcode *code = QRcode_encodeString([QRCode UTF8String], 0, QR_ECLEVEL_L, QR_MODE_8, 1);
    if (!code) {
        return nil;
    }
    
    // create context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(0, size, size, 8, size * 4, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0, -size);
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1, -1);
    CGContextConcatCTM(ctx, CGAffineTransformConcat(translateTransform, scaleTransform));
    
    // draw QR on this context
    unsigned char *data = 0;
    int width;
    data = code->data;
    width = code->width;
    float zoom = (double)size / (code->width + 2.0 * qr_margin);
    CGRect rectDraw = CGRectMake(0, 0, zoom, zoom);
    
    // draw
    CGContextSetFillColor(ctx, CGColorGetComponents([UIColor blackColor].CGColor));
    for(int i = 0; i < width; ++i) {
        for(int j = 0; j < width; ++j) {
            if(*data & 1) {
                rectDraw.origin = CGPointMake((j + qr_margin) * zoom,(i + qr_margin) * zoom);
                CGContextAddRect(ctx, rectDraw);
            }
            ++data;
        }
    }
    CGContextFillPath(ctx);
    
    
    // get image
    CGImageRef qrCGImage = CGBitmapContextCreateImage(ctx);
    UIImage * qrImage = [UIImage imageWithCGImage:qrCGImage];
    
    // some releases
    CGContextRelease(ctx);
    CGImageRelease(qrCGImage);
    CGColorSpaceRelease(colorSpace);
    QRcode_free(code);
    
    return qrImage;

}

//==>滤镜功能
+ (UIImage*)imageWithImage:(UIImage*)inImage colorMatrix:(NSString*) colorMatrix {
    CGRect rectMatix = CGRectMake(0, 0, 0, 0);
    rectMatix.size = inImage.size;
    return [self imageWithImage:inImage colorMatrix:colorMatrix rectMatrix:rectMatix];
}
//可以打印出所有的过滤器以及支持的属性
//NSArray *filters = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
//for (NSString *filterName in filters) {
//    CIFilter *filter = [CIFilter filterWithName:filterName];
//    NSLog(@"%@,%@",filterName,[filter attributes]);
//}
+ (UIImage*)imageWithImage:(UIImage*)inImage colorMatrix:(NSString*) colorMatrix rectMatrix:(CGRect) rectMatrix{
    @try {
        CIImage *ciImage = [[CIImage alloc] initWithImage:inImage];
        
        CIFilter *filter = [CIFilter filterWithName:colorMatrix];
        [filter setValue:ciImage forKey:kCIInputImageKey];
        [filter setDefaults];
        //创建基于GPU的CIContext
        CIContext *context = [CIContext contextWithOptions:nil];
        CIImage *outputImage = [filter outputImage];
        CGImageRef cgImage = [context createCGImage:outputImage fromRect:rectMatrix];
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        return image;
    }
    @catch (NSException *exception) {
        return nil;
    }
}
//<==
/**
 毛玻璃
 @blur 透明度
 @tintColor 毛玻璃颜色
 */



-(UIImage * _Nonnull) applyEffect:(CGFloat)blur tintColor:(nullable UIColor *) tintColor{
    
    CGImageRef img = self.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    //create vImage_Buffer with data from CGImageRef
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL){
        NSLog(@"No pixelbuffer");
    }
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    // Create a third buffer for intermediate processing
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    uint32_t boxSize = (uint32_t)(blur * MIN(outBuffer.width, outBuffer2.height) * .1);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef outputContext = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGImageAlphaNoneSkipLast);
    
    // Add in color tint.
    if (tintColor) {
        CGRect imageRect = {CGPointZero, self.size};
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    CGImageRef imageRef = CGBitmapContextCreateImage(outputContext);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(outputContext);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    free(pixelBuffer2);
    
    CFRelease(inBitmapData);
    CGImageRelease(imageRef);
    
    
    
    return returnImage;
}


@end
