//
//  MResourceUtility.h
//  MResourceLoader
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

#define MRAsset(obj,desc,returnValue) if(!obj){ NSAssert(0, desc);return (returnValue);}

#define MRDEBUG

#if defined (MRDEBUG) && defined (DEBUG)
    #define MRLog(...) NSLog(__VA_ARGS__)
#else
    #define MRLog(...)
#endif

#define MRRANGE_UNDEFINE INT_MAX

#define MRLong long long

typedef struct _MRRange {
    MRLong location;
    NSUInteger length;
} MRRange;

NS_INLINE MRRange MRMakeRange(MRLong loc, NSUInteger len) {
    MRRange r;
    r.location = loc;
    r.length = len;
    return r;
}

NS_INLINE MRLong MRMaxRange(MRRange range) {
    return (range.location + range.length);
}

