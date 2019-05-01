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

+ (UIImage *)processImage:(UIImage *) source;
+ (UIImage *)processVideo:(NSString *) videoURLString;

@end

#endif /* OpenCVWrapper_h */
