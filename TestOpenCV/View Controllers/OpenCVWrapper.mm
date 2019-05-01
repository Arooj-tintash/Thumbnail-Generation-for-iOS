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

+ (Mat)_grayFrom:(Mat)source;
+ (Mat) _gaussianBlur:(Mat)source;
+ (Mat)_matFrom:(UIImage *)source;
+ (UIImage *)_imageFrom:(Mat)source;

+(vector<Mat>)_videoParser:(NSString *)filepath;
+(UIImage *)processVideo:(NSString *)filepath;

+(Mat) hecate_code:(NSString *) source;
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
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"testVideo" ofType:@"mp4"];
    std::string _filepath = std::string([filePath UTF8String]);
    
    video_parser *parser = new video_parser();
    struct parser_params opt;
    vector<Mat> videoFrame = parser->parse_video(_filepath, opt);

    int sizeOfframes =videoFrame.size();
    
    Mat selectedFrame = videoFrame[sizeOfframes-1];
    Mat rgbFrame;
    cv::cvtColor(selectedFrame, rgbFrame, CV_BGR2RGB);
    
    return [OpenCVWrapper _imageFrom: rgbFrame];
//    return [OpenCVWrapper _imageFrom: frames[sizeOfframes-1]];
}

#pragma mark Private

//+ (vector<Mat>) _videoParser:(NSString *)filepath {
//    cout << "-> Video Parser ->";
//    std::string _filepath = std::string([filepath UTF8String]);
//
//
//    cv::VideoCapture vidCap = cv::VideoCapture(_filepath);
//    if(!vidCap.isOpened()) NSLog(@"Could not open testVideo.mp4");
//
//    vector<Mat> frames;
//
//    //Seek video to last frame
//
//    bool isFrame = true;
//    while (isFrame) {
//        cv::Mat frame;
//        isFrame = vidCap.read(frame);
//
//        if(isFrame){
//            frames.push_back(frame); //get a new frame
//        }
//    }
//    cout << "No of frames: " << frames.size();
//   return  frames;
//}
//
//+ (Mat) hecate_code:(NSString *) filePath {
//    // Read input params
//    hecate_params opt;
//    // Read input params
//
//    //hecate_parse_params( filePath, argv, opt );
//    Mat frame;
//    // Run VIDSUM
//    vector<int> v_thumb_idx;
//    vector<hecate::Range> v_gif_range;
//    vector<hecate::Range> v_mov_range;
//    run_hecate( opt, v_thumb_idx, v_gif_range, v_mov_range );
//
//    // Print debugging info
//    if( opt.debug ) {
//        if( opt.jpg ) {
//            printf("hecate: thumbnail indices: [ ");
//            for(size_t i=0; i<v_thumb_idx.size(); i++)
//                printf("%d ", v_thumb_idx[i]);
//            printf("]\n");
//        }
//    }
//
//    // Produce results
//    if( opt.jpg ) {
//      frame =  generate_thumbnails( opt, v_thumb_idx );
//    }
//    return frame;
//}

+ (Mat)_grayFrom:(Mat)source {
    cout << "-> grayFrom ->";
    
    Mat result;
    cvtColor(source, result, CV_BGR2GRAY);
    return result;
}

+ (Mat)_gaussianBlur:(Mat)source {
    cout << "-> GaussianBlur ->";
    Mat result;
//    cv::Size my_size = Size_<int>(11, 11);	
    
    //cv::blur(source, result, my_size);
    // Dilate
    //dilate(InputArray src, <#OutputArray dst#>, <#InputArray kernel#>)
    
    //cv::erode(source, result, Mat(), cv::Point(-1,-1));
    
    cv::threshold(source, result, 30, 255, CV_THRESH_BINARY | CV_THRESH_OTSU);
    //cvSmooth(pGrayImg, pGrayImg, CV_BLUR, 2, 2);

   // cv::GaussianBlur(source, result, my_size, 5.0,5.0);
    //applying Gaussian filter
    
    //result = source;
    return result;
}

+ (Mat)_processImage:(Mat)source {
    Mat result;
    Mat grayImage;
    
    grayImage = [OpenCVWrapper _grayFrom:source];
    result = [OpenCVWrapper _gaussianBlur:grayImage];
    
    return result;
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
