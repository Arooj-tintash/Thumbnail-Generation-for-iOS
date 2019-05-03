//
//  thumbnail.h
//  TestOpenCV
//
//  Created by Mac Mini on 02/05/2019.
//  Copyright © 2019 TestOpenCV. All rights reserved.
//

#ifndef thumbnail_h
#define thumbnail_h


#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <getopt.h>
#include <sys/stat.h> // mkdir
#include <unistd.h>   // access() function

#include <ctime>      // display date and time
#include <iostream>   // for standard I/O
#include <fstream>    // for file I/O
#include <string>     // for strings
#include <iomanip>    // for controlling float print precision
#include <sstream>    // string to number conversion
#include <chrono>
#include <limits>
#include <numeric>

// OpenMP library
#if defined(_OPENMP)
#include <omp.h>
#endif

// Hecate headers
#include "my_sort.h"
#include "gapstat.h"
#include "video_parser.h"
#include "time.h"
#include "shot_range.h"

// OpenCV library
#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/ml/ml.hpp>

using namespace std;

// program options
struct thumbnail_params {
    int step_sz;          // frame subsampling step size
    bool gfl;             // run group-fused lasso as part of shot segmentation
    double fltr_begin_sec_thumb;// always filter out x-second frames at the beginning
    double fltr_end_sec_thumb;  // always filter out x-second frames at the end
    int max_duration;     // maximum length of video to process (in seconds)
    int jpg_width_px;     // thumbnail image width
    bool info_shot;       // print shot boundary info
    bool info_keyfrm;     // print key frame indices
    bool jpg;             // generate thumbnail jpg
    int njpg;             // number of thumbnail images
    bool debug;
    
    thumbnail_params():
    step_sz(1),
    gfl(false),
    fltr_begin_sec_thumb(-1.0),
    fltr_end_sec_thumb(-1.0),
    max_duration(-1),
    jpg_width_px(360),
    info_shot(false),
    info_keyfrm(false),
    jpg(true),
    njpg(5),
    debug(true)
    {};
};


/*******************************************************************************
 
 THUMBNAIL INTERFACE
 
 INPUT:
 hecate_params opt : input option paramaters
 
 OUTPUT:
 vector<int> v_thumb_idx : thumbnail frame indices
 
 *******************************************************************************/
vector<Mat> run_thumbnail(const string& in_video, thumbnail_params& opt,
                vector<int>& v_thumb_idx);

/*******************************************************************************
 
 THUMBNAIL IMAGE GENERATION MODULE
 
 INPUT:
 hecate_params opt        : input option paramaters
 video_metadata meta      : video metadata
 vector<hecate::ShotRanges> v_shot_range
 : shot boundaries
 const Mat& X             : input features
 const Mat& diff          : n-by-1 vector of frame-by-frame difference scores
 
 OUTPUT:
 vector<int> v_thumb_idx  : vector of frame index numbers for thumbnails
 
 *******************************************************************************/

void detect_thumbnail_frames( thumbnail_params& opt,
                             video_metadata& meta,
                             const vector<ShotRange>& v_shot_range,
                             const Mat& X,
                             const Mat& diff,
                             vector<int>& v_thumb_idx);

vector<Mat> generate_thumbnails(const string &in_video, thumbnail_params& opt, vector<int>& v_thumb_idx );

#endif /* thumbnail_h */
