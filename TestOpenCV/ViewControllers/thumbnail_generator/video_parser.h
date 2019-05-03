//
//  video_parser.hpp
//  TestOpenCV
//
//  Created by Mac Mini on 22/04/2019.
//  Copyright © 2019 TestOpenCV. All rights reserved.

#ifndef video_parser_h
#define video_parser_h

#include <stdio.h>

// OpenMP library
#if defined(_OPENMP)
#include <omp.h>
#endif

#undef NO
#undef YES

// OpenCV library
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

#include "my_sort.h"
#include "gflseg.h"
#include "hist_opencv.h"
#include "image_metrics.h"
#include "shot_range.h"
#include "gapstat.h"

using namespace std;
using namespace cv;

// video metadata struct
struct video_metadata {
    int nframes;
    int width;
    int height;
    double duration; // in seconds
    double fps;
};

struct parser_params {
    double fltr_begin_sec;
    double fltr_end_sec;
    double max_duration;
    int step_sz;
    bool ignore_rest; // if video is too long, ignore the rest (true) or
    // adjust step_sz (false). for vidtag this should be
    // false, while for hecate this should be true
    bool gfl;      // use group-fused lasso to refine boundaries
    bool fltr_rdt; // filter redundant frames
    bool fltr_lq;  // filter low-quality frames
    bool debug;
    
    parser_params():
    fltr_begin_sec(0),
    fltr_end_sec(0),
    max_duration(-1),
    gfl(false),
    step_sz(1),
    fltr_rdt(true),
    ignore_rest(false),
    fltr_lq(true),
    debug(false)
    {};
};

//inline void print_video_metadata( const string filename,
//                                 const video_metadata m ) {
//    printf("%s\n  seconds=%.2f, nframes=%d, fps=%.2f, resolution=%dx%d\n",
//           filename.c_str(), m.duration, m.nframes, m.fps, m.width, m.height);
//};
    
class video_parser {
public:
    
    /* Temporary thumbnail */
    vector<Mat> frameExtraction(const string& in_video);
    
    //Return all the frames for video
    vector<ShotRange> parse_video(const string& in_video, parser_params opt);
    
    /* Get the number of valid frames */
    int get_nfrm_valid();
    
    /* Display video with shot boundary information */
    void play_video_filtered(const string& in_video,
                             int step_sz=1,
                             int max_frm_len=360);
    
    /* Get a vector of booleans representing valid frames */
    inline void get_frm_valid(vector<bool>& vec) {vec=_v_frm_valid;}
    
    /* Get effective step size */
    inline int get_effective_step_size() {return _step_sz;}
    
    /* Get extracted features */
    inline const Mat get_frame_features() {return _X_feat;}
    inline const Mat get_frame_diff_features() {return _X_diff;}
    
private:
    
    /* Read video into the memory */
    int read_video(const string& in_video,
                           int step_sz=1,
                           double max_duration=30*60,
                           bool ignore_rest=true,
                           int max_frm_len=160);
    
    /* Filter out low-quality frames */
    void filter_low_quality(double thrsh_bright=0.075,
                            double thrsh_sharp=0.08,
                            double thrsh_uniform=0.80);
    
    /* Filter out frames during transition */
    void filter_transition(double thrsh_diff=0.50,
                           double thrsh_ecr=0.10 );
    
    /* Filter out redundant frames */
    void filter_redundant_and_obtain_subshots();
    
    /* Update shot ranges, filter out shots if too short */
    void update_shot_ranges(int min_shot_len=5);    
    
    /* Perform post processing. Break up shots if too long */
    void post_process(double min_shot_sec=2.0, bool gfl=false);
    
    /* Perform SBD using heuristics: add next big diff if
     the new shot length is longer than min_shot_len */
    void sbd_heuristic(vector<double> v_diff, vector<int>& jump,
                       int njumps, int min_shot_len );
    
    // Helper functions
    
    /* Extract pyramid of histogram features */
    void extract_histo_features(int pyr_level=2,
                                bool omit_filtered=true,
                                int nbin_color_hist=128,
                                int nbin_edge_ori_hist=8,
                                int nbin_edge_mag_hist=8);
    
    void mark_invalid( vector<bool>& vec, int idx, int wnd_sz=0 );
    void mark_invalid( vector<bool>& vec, vector<string>& vec2,
                      int idx, const string msg, int wnd_sz=0 );
    
    void release_memory();
    
public:
    video_metadata meta;
    vector<bool> _v_frm_valid;    // filtered frames
    vector<string> _v_frm_log;    // filtered frames msgs (debug)
    vector<ShotRange> _v_shot_ranges;

private:
    double _video_fps;
    bool _debug;
    int _nfrm_total;   // number of frames BEFORE sampling
    int _nfrm_given;   // number of frames AFTER sampling
    int _video_width;
    int _video_height;
    double _video_sec;
    int _step_sz;
    bool _display;
   
    Mat _X_feat; // frame-wise feature representation
    Mat _X_diff; // n-by-1 frame-by-frame difference first-order derivative
    Mat _X_ecr;  // n-by-1 ecr first-order derivative
    
    vector<Mat> _v_frm_rgb;       // rgb frames
    vector<Mat> _v_frm_gray;      // gray-scale frames
};

#endif

