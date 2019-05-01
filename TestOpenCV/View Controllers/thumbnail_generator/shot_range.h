//
//  shot_range.h
//  TestOpenCV
//
//  Created by Mac Mini on 30/04/2019.
//  Copyright © 2019 TestOpenCV. All rights reserved.
//

#ifndef shot_range_h
#define shot_range_h


#include <string>
#include <vector>

#include "my_sort.h"
    
    /*
     */
    class my_range {
    public:
        int start;
        int end;
        vector<int> v_idx; // store indices (keyframe index)
        
    public:
        my_range(int s, int e): start(s), end(e) {};
        
        inline int length() const { return end-start+1; };
        
        inline void print() const {
            printf("range(%d:%d) (%d) [", start, end, length() );
            for(size_t i=0; i<v_idx.size(); i++) {
                printf("%d", v_idx[i]);
                if( i+1<v_idx.size() )
                    printf(",");
            }
            printf("]\n");
        };
    };
    
    /*
     */
    class ShotRange: public my_range {
    public:
        vector<my_range> v_range;
        
    public:
        ShotRange(int s, int e): my_range(s,e) {};
        
        inline void print() const {
            printf("shot_range(%d:%d) (%d) [", start, end, length() );
            for(size_t i=0; i<v_idx.size(); i++) {
                printf("%d", v_idx[i]);
                if( i+1<v_idx.size() )
                    printf(",");
            }
            printf("]\n");
            
            for(size_t i=0; i<v_range.size(); i++) {
                printf("  sub_");
                v_range[i].print();
            }
        };
    };
    
    /*
     */
    class Tag {
    public:
        string label;
        double score;
        
    public:
        Tag(string& l, double s): label(l), score(s) {};
        
        inline void print() const {
            printf("(%s,%f)", label.c_str(), score);
        }
    };
    
    /*
     */
    class RangeTag: public my_range {
    public:
        vector<Tag> v_tag;
        
    public:
        RangeTag(int s, int e): my_range(s,e) {};
        RangeTag(my_range r): my_range(r.start,r.end) {
            v_idx=r.v_idx;
        };
        
        inline void print() const {
            printf("range(%d:%d) (%d) [", start, end, length() );
            for(size_t i=0; i<v_idx.size(); i++) {
                printf("%d", v_idx[i]);
                if( i+1<v_idx.size() )
                    printf(",");
            }
            printf("], tags: ");
            for(size_t i=0; i<v_tag.size(); i++)
                v_tag[i].print();
            printf("\n");
        };
        
        inline void sort() {
            vector<double> v_scores;
            for(size_t i=0; i<v_tag.size(); i++)
                v_scores.push_back( v_tag[i].score );
            vector<double> v_srtval;
            vector<size_t> v_srtidx;
            my_sort( v_scores, v_srtval, v_srtidx );
            vector<Tag> v_tag_new;
            for(size_t i=0; i<v_srtidx.size(); i++)
                v_tag_new.push_back( v_tag[v_srtidx[v_srtidx.size()-1-i]] );
            v_tag = v_tag_new;
        }
    };
    
    /*
     */
    class ShotRangeTag: public my_range {
    public:
        vector<RangeTag> v_range_tag;
        
    public:
        ShotRangeTag(int s, int e): my_range(s,e) {};
        ShotRangeTag(ShotRange& sr): my_range(sr.start,sr.end) {
            v_idx = sr.v_idx;
            for(size_t i=0; i<sr.v_range.size(); i++) {
                RangeTag rt( sr.v_range[i] );
                v_range_tag.push_back( rt );
            }
        };
        
        inline void print() {
            printf("shot_range_tag(%d:%d) (%d) [", start, end, length() );
            for(size_t i=0; i<v_idx.size(); i++) {
                printf("%d", v_idx[i]);
                if( i+1<v_idx.size() )
                    printf(",");
            }
            printf("]\n");
            
            for(size_t i=0; i<v_range_tag.size(); i++) {
                printf("  sub_");
                v_range_tag[i].print();
            }
        };
        
        inline void sort() {
            for(size_t i=0; i<v_range_tag.size(); i++)
                v_range_tag[i].sort();
        };
    };

#endif /* shot_range_h */
