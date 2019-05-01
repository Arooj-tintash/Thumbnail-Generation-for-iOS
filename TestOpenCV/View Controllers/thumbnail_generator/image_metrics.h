//
//  Header.h
//  TestOpenCV
//
//  Created by Mac Mini on 30/04/2019.
//  Copyright © 2019 TestOpenCV. All rights reserved.
//

#ifndef image_metrics_h
#define image_metrics_h

#include <math.h>
#include <stdio.h>
#include <cmath>
#include <string>
#include <vector>

#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include "hist_opencv.h"


using namespace cv;
using namespace std;

#define VALIDATE(x) ( std::isnan(x) ) ? 0 : x

/*------------------------------------------------------------------------
 Sharpness is measured as the sum of magnitude in frequency domain
 ------------------------------------------------------------------------*/
inline double calc_sharpness( const Mat& gray_img )
/*-----------------------------------------------------------------------*/
{
    Mat img;
    gray_img.convertTo( img, CV_32FC1 );
    img *= 1./255;
    
    Mat dx, dy;
    Sobel( img, dx, img.type(), 1, 0, 3 );
    Sobel( img, dy, img.type(), 0, 1, 3 );
    magnitude( dx, dy, dx );
    
    int npixels = gray_img.rows * gray_img.cols;
    return VALIDATE(cv::sum(dx)[0] / npixels);
}

/*------------------------------------------------------------------------
 Brightness is measured as the relative luminance in colorimetric spaces
 https://en.wikipedia.org/wiki/Relative_luminance
 ------------------------------------------------------------------------*/
inline double calc_brightness( const Mat& img )
/*-----------------------------------------------------------------------*/
{
    vector<Mat> bgr;
//    Mat channels[3];
//    bgr.push_back(img);
    split( img, bgr );
    for(size_t j=0; j<bgr.size(); j++)
        bgr[j].convertTo(bgr[j],CV_32F);
    
    // compute perceived brightness
    Mat img_pb = (0.2126*bgr[2] + 0.7152*bgr[1] + 0.0722*bgr[0])/255.0;
    return VALIDATE(mean( img_pb )[0]);
}

/*------------------------------------------------------------------------
 Uniformness is measured as the ratio between the 5% percentile pixel
 intensity histograms and the rest.
 ------------------------------------------------------------------------*/
inline double calc_uniformity( const Mat& gray_img, int nbins=128 )
/*-----------------------------------------------------------------------*/
{
    double val = 0.0;
    
    Mat ghist;
    calc_gray_hist( gray_img, ghist, nbins );
    if( cv::sum(ghist)[0] == 0 ) {
        val = 1.0;
    }
    else {
        Mat hist_sorted;
        cv::sort( ghist, hist_sorted, CV_SORT_EVERY_COLUMN|CV_SORT_DESCENDING );
        hist_sorted /= cv::sum( hist_sorted )[0];
        for(int j=0; j<(int)(0.05*nbins); j++)
            val += (double) hist_sorted.at<float>(j);
    }
    return VALIDATE(val);
}

#endif /* Header_h */
