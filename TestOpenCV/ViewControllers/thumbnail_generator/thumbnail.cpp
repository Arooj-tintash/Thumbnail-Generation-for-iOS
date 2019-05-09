//
//  thumbnail.m
//  TestOpenCV
//
//  Created by Mac Mini on 02/05/2019.
//  Copyright © 2019 TestOpenCV. All rights reserved.
//

#include "thumbnail.h"

using namespace std;
using namespace cv;

vector<Mat> run_thumbnail(const string &in_video, thumbnail_params& opt, vector<int>& v_thumb_idx)
{
    cout << " Function run thumbnail -> ";
//    if( !file_exists(opt.in_video) ) {
//        fprintf(stderr, "File not exist: %s\n", opt.in_video.c_str());
//        return;
//    }
    
    v_thumb_idx.clear();
    
//    thumbnail::Clock::time_point t0;
    video_parser parser;
    
    vector<ShotRange> v_shot_range;
    Mat histo_features;
    Mat diff_features;
    
    ////////////////////////////////////////////////////////////////////////////
    //
    // Parse video
    //
    ////////////////////////////////////////////////////////////////////////////
//    if( opt.debug ) {
//        printf("run_hecate: Video segmentation and keyframe extraction\n");
////        t0 = thumbnail::Clock::now();
//    }
    
    parser_params parser_opt;
    parser_opt.step_sz = opt.step_sz;
    parser_opt.gfl = opt.gfl;

    parser_opt.fltr_begin_sec = ( opt.fltr_begin_sec_thumb<0 )
    ? max(0.5, 0.05 * parser.meta.duration) : opt.fltr_begin_sec_thumb;
    parser_opt.fltr_end_sec = ( opt.fltr_end_sec_thumb<0 )
    ? max(0.5, 0.10 * parser.meta.duration) : opt.fltr_end_sec_thumb;
    parser_opt.max_duration = opt.max_duration;
    parser_opt.ignore_rest = (opt.max_duration>0); // ignore parts after max_nfrms
    parser_opt.debug = opt.debug;
    
    // PARSE
    v_shot_range = parser.parse_video(in_video, parser_opt );
    if( v_shot_range.empty() ) {
        fprintf(stderr, "run_thumbnail: Failed to parse the video\n");
//        return;
    }
    for(size_t i=0; i<v_shot_range.size(); i++) {
        printf("[%d:%d]", v_shot_range[i].start, v_shot_range[i].end);
        if( i<v_shot_range.size()-1 )
            printf(",");
    }
    
    histo_features = parser.get_frame_features();
    diff_features  = parser.get_frame_diff_features();
    opt.step_sz    = parser.get_effective_step_size();
    
    // Check desired resolution of output
    if( opt.jpg_width_px<0 || opt.jpg_width_px > parser.meta.width ) {
        fprintf( stderr, "run_thumbnail: Forcing jpg_width_px to %d\n",parser.meta.width);
        opt.jpg_width_px = parser.meta.width;
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //
    // Analyze video
    //
    ////////////////////////////////////////////////////////////////////////////
    
    // Print shot info
    if( opt.info_shot ) {
        printf("shots: ");
        for(size_t i=0; i<v_shot_range.size(); i++) {
            printf("[%d:%d]", v_shot_range[i].start, v_shot_range[i].end);
            if( i<v_shot_range.size()-1 )
                printf(",");
        }
        printf("\n");
    }
    
    // Print keyframe indices
    if( opt.info_keyfrm ) {
        vector<int> keyfrms;
        for(size_t i=0; i<v_shot_range.size(); i++) {
            for(size_t j=0; j<v_shot_range[i].v_idx.size(); j++) {
                keyfrms.push_back(v_shot_range[i].v_idx[j]);
            }
        }
        
        printf("keyframes: [");
        for(size_t i=0; i<keyfrms.size(); i++) {
            printf("%d", keyfrms[i]);
            if( i<keyfrms.size()-1 )
                printf(",");
        }
        printf("]\n");
    }
    
    // Thumbnail extraction module
    if( opt.jpg ) {
        if( opt.debug ) {
            printf("run_thumbnail: Video keyframe detection\n");
//            t0 = thumbnail::Clock::now();
        }
    
        detect_thumbnail_frames( opt, parser.meta, v_shot_range,
                            histo_features, diff_features,
                            v_thumb_idx);
    }
    
    vector<Mat> thumbnail_frame;
    
    // Print debugging info
    if( opt.debug ) {
        if( opt.jpg ) {
            printf("thumbnail indices: [ ");
            for(size_t i=0; i<v_thumb_idx.size(); i++)
                printf("%d ", v_thumb_idx[i]);
            printf("]\n");
        }
    }
    
    // Produce results
    if( opt.jpg ) {
        thumbnail_frame = generate_thumbnails(in_video, opt, v_thumb_idx );
    }
    
//        cout << thumbnail_frame.size();
    return thumbnail_frame;
}

