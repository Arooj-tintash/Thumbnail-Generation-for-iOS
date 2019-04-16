//
//  OpenCVWrapper.h
//  TestOpenCV
//
//  Created by Mac Mini on 05/04/2019.
//  Copyright © 2019 TestOpenCV. All rights reserved.
//

#ifndef OpenCVWrapper_h
#define OpenCVWrapper_h

#import <UIKit/UIKit.h>
//#import <opencv2/opencv.hpp>

@interface OpenCVWrapper : NSObject
//+ (cv::Mat)toGray:(UIImage *) source;
//+ (UIImage *)toBlur:(UIImage *) source;
//+ (UIImage *)toFilter:(cv::Mat) source;

+ (UIImage *)processImage:(UIImage *) source;
@end

#endif /* OpenCVWrapper_h */
