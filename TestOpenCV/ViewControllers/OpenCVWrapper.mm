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
+ (NSMutableArray *)_imageFrom:(vector<Mat>)source;

//+ (NSMutableArray *) processVideo:(NSString *)filepath;

#endif

@end

#pragma mark - OpenCVWrapper

@implementation OpenCVWrapper

#pragma mark Public
//+ (UIImage *)processImage:(UIImage *)source {
//    cout << "OpenCV Filters";
//    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _processImage:[OpenCVWrapper _matFrom:source]]];
//}

+ (NSMutableArray *)processVideo:(NSString *)filepathParam {
    cout << "OpenCV Filters";
    std::string _filepath = std::string([filepathParam UTF8String]);
    
    video_parser *parser = new video_parser();
    vector<Mat> videoFrame = parser->frameExtraction(_filepath);

    size_t sizeOfframes =videoFrame.size();
    cout << "\n Size of frame " << sizeOfframes;
    vector<Mat> selectedFrame; //= videoFrame[sizeOfframes-1];
    
    selectedFrame.assign( videoFrame.size(), Mat() );
    
    for(int i=0; i < sizeOfframes-1; i++) {
        Mat rgbFrame;
        cv::cvtColor(videoFrame[i], rgbFrame, CV_BGR2RGB);
        rgbFrame.copyTo(selectedFrame[i]);
    }
    
    return [OpenCVWrapper _imageFrom: selectedFrame];
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

+ (NSMutableArray *)_imageFrom:(vector<Mat>)source {
    cout << "-> imageFrom\n";
    
    NSMutableArray *result = [[NSMutableArray alloc] init];

    for(int i=0; i< source.size()-1; i++) {
        NSData *data = [NSData dataWithBytes:source[i].data length:source[i].elemSize() * source[i].total()];
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);

        CGBitmapInfo bitmapFlags = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
        size_t bitsPerComponent = 8;
        size_t bytesPerRow = source[i].step[0];
        CGColorSpaceRef colorSpace = (source[i].elemSize() == 1 ? CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB());

        CGImageRef image = CGImageCreate(source[i].cols, source[i].rows, bitsPerComponent, bitsPerComponent * source[i].elemSize(), bytesPerRow, colorSpace, bitmapFlags, provider, NULL, false, kCGRenderingIntentDefault);
        UIImage * resultImg  = [UIImage imageWithCGImage:image];
        [result addObject:resultImg];

        CGImageRelease(image);
        CGDataProviderRelease(provider);
        CGColorSpaceRelease(colorSpace);
    }

//    // Colorspace
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//
//    for(int i=0; i < source.size()-1; i++) {
//    unsigned char* data = new unsigned char[4*source[i].cols*source[i].rows];
//    for (int y = 0; y < source[i].rows; ++y)
//    {
//        cv::Vec3b *ptr = source[i].ptr<cv::Vec3b>(y);
//        unsigned char *pdata = data + 4*y*source[i].cols;
//
//        for (int x = 0; x < source[i].cols; ++x, ++ptr)
//        {
//            *pdata++ = (*ptr)[2];
//            *pdata++ = (*ptr)[1];
//            *pdata++ = (*ptr)[0];
//            *pdata++ = 0;
//        }
//    }
//
//    // Bitmap context
//    CGContextRef context = CGBitmapContextCreate(data, source[i].cols, source[i].rows, 8, 4*source[i].cols, colorSpace, kCGImageAlphaNoneSkipLast);
//
//    CGImageRef cgimage = CGBitmapContextCreateImage(context);
//    UIImage *resultImg = [UIImage imageWithCGImage:cgimage];
//    [result addObject:resultImg];
//
//    CGColorSpaceRelease(colorSpace);
//    CGContextRelease(context);
//    delete[] data;
//
//    }
    
    
    return result;
}

@end
