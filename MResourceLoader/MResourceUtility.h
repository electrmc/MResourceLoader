//
//  MResourceUtility.h
//  MResourceDemo
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MPAsset(obj,desc,returnValue) if(!obj){ NSAssert(0, desc);return (returnValue);}

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

