//
//  NSString+MRResourceUtility.m
//  MResourceLoader
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "NSString+MRResourceUtility.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MRResourceUtility)

- (NSString*)mr_md5 {
    const char* str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

+ (NSString*)stringFromRange:(MRRange) range {
    return [NSString stringWithFormat:@"%lld-%ld",range.location,range.length];
}

- (MRRange)MRRange {
    NSArray<NSString*> *ary = [self componentsSeparatedByString:@"-"];
    if (ary.count != 2) {
        return MRMakeRange(MRRANGE_UNDEFINE, MRRANGE_UNDEFINE);
    }
    return MRMakeRange([ary[0] longLongValue], [ary[1] integerValue]);
}

@end
