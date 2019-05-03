//
//  OpenCVWrapper.m
//  TestOpenCV
//
//  Created by Mac Mini on 05/04/2019.
//  Copyright © 2019 TestOpenCV. All rights reserved.
//



#undef NO
#undef YES

#ifdef __cplusplus
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdocumentation"

#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"

#import <Foundation/Foundation.h>
//#pragma clang pop
#endif

using namespace cv;
using namespace std;

#include "video_parser.h"

#pragma mark - Private Declarations

@interface OpenCVWrapper ()

#ifdef __cplusplus

+ (Mat) _grayFrom:(Mat)source;
+ (Mat) _gaussianBlur:(Mat)source;

+ (Mat)_matFrom:(UIImage *)source;
+ (UIImage *)_imageFrom:(Mat)source;

+(UIImage *) processVideo:(NSString *)filepath;

#endif

@end

#pragma mark - OpenCVWrapper

@implementation OpenCVWrapper

#pragma mark Public
+ (UIImage *)processImage:(UIImage *)source {
    cout << "OpenCV Filters";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _processImage:[OpenCVWrapper _matFrom:source]]];
}

+ (UIImage *)processVideo:(NSString *)filepathParam {
    cout << "OpenCV Filters";
    std::string _filepath = std::string([filepathParam UTF8String]);
    
    video_parser *parser = new video_parser();
    vector<Mat> videoFrame = parser->frameExtraction(_filepath);

    size_t sizeOfframes =videoFrame.size();
    cout << '\n Size of frame' << sizeOfframes;
    Mat selectedFrame = videoFrame[sizeOfframes-1];
    Mat rgbFrame;
    cv::cvtColor(selectedFrame, rgbFrame, CV_BGR2RGB);
    
    return [OpenCVWrapper _imageFrom: rgbFrame];
}

#pragma mark Private

+ (Mat)_grayFrom:(Mat)source {
    cout << "-> grayFrom ->";
    
    Mat result;
    cvtColor(source, result, CV_BGR2GRAY);
    return result;
}

+ (Mat)_gaussianBlur:(Mat)source {
    cout << "-> GaussianBlur ->";
    Mat result;
    cv::Size my_size = Size_<int>(11, 11);
    
    //cv::blur(source, result, my_size);
    // Dilate
    //dilate(InputArray src, <#OutputArray dst#>, <#InputArray kernel#>)
    
    //cv::erode(source, result, Mat(), cv::Point(-1,-1));
    
//    cv::threshold(source, result, 30, 255, CV_THRESH_BINARY | CV_THRESH_OTSU);
    //cvSmooth(pGrayImg, pGrayImg, CV_BLUR, 2, 2);

    cv::GaussianBlur(source, result, my_size, 5.0,5.0);
    //applying Gaussian filter

    return result;
}

+ (Mat)_processImage:(Mat)source {
    Mat result;
    Mat grayImage;
    
    grayImage = [OpenCVWrapper _grayFrom:source];
    
    return grayImage;
}


+ (Mat)_matFrom:(UIImage *)source {
    cout << "matFrom ->";
    
    CGImageRef image = CGImageCreateCopy(source.CGImage);
    CGFloat cols = CGImageGetWidth(image);
    CGFloat rows = CGImageGetHeight(image);
    Mat result(rows, cols, CV_8UC4);
    
    
    CGBitmapInfo bitmapFlags = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = result.step[0];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);
    
    CGContextRef context = CGBitmapContextCreate(result.data, cols, rows, bitsPerComponent, bytesPerRow, colorSpace, bitmapFlags);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, cols, rows), image);
    CGContextRelease(context);
    
    return result;
}

+ (UIImage *)_imageFrom:(Mat)source {
    cout << "-> imageFrom\n";
    
    NSData *data = [NSData dataWithBytes:source.data length:source.elemSize() * source.total()];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);

    CGBitmapInfo bitmapFlags = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = source.step[0];
    CGColorSpaceRef colorSpace = (source.elemSize() == 1 ? CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB());

    CGImageRef image = CGImageCreate(source.cols, source.rows, bitsPerComponent, bitsPerComponent * source.elemSize(), bytesPerRow, colorSpace, bitmapFlags, provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *result = [UIImage imageWithCGImage:image];

    CGImageRelease(image);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return result;
}

@end
