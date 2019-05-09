//
//  file_helper.h
//  TestOpenCV
//
//  Created by Mac Mini on 06/05/2019.
//  Copyright © 2019 TestOpenCV. All rights reserved.
//

#ifndef file_helper_h
#define file_helper_h

#include <stdio.h>
#include <string.h>

#include <iostream>
#include <fstream>
#include <algorithm>
#include <functional>
#include <cctype>
#include <locale>
#include <string>
#include <vector>

struct FileParts
{
    std::string path;
    std::string name;
    std::string ext;
};

static inline FileParts fileparts(std::string filename)
{
    int idx0 = filename.rfind("/");
    int idx1 = filename.rfind(".");
    
    if( idx1 == (int) std::string::npos )
        idx1 = filename.length();
    
    FileParts fp;
    fp.path = filename.substr(0,idx0+1);
    fp.name = filename.substr(idx0+1,idx1-idx0-1);
    fp.ext  = filename.substr(idx1);
    
    return fp;
};

static inline std::string get_filename( std::string filepath ) {
    FileParts fp = fileparts( filepath );
    std::string filename = fp.name;
    replace( filename.begin(), filename.end(), ' ', '_' );
    return filename;
};

#endif /* file_helper_h */
