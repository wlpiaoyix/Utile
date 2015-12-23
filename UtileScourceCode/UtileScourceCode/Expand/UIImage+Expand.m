//
//  UIImage+Convenience.m
//  AKSL-189-Msp
//
//  Created by AKSL-td on 13-12-3.
//  Copyright (c) 2013年 AKSL. All rights reserved.
//

#import "UIImage+Expand.h"
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

@end
