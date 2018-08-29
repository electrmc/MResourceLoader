//
//  MResourceContentInfo.m
//  MResourceLoader
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "MResourceContentInfo.h"

static NSString * const ContentTypeKey = @"ContentTypeKey";
static NSString * const ContentLengthKey = @"ContentLengthKey";
static NSString * const ByteRangeAccessSupportedKey = @"ByteRangeAccessSupportedKey";

@implementation MResourceContentInfo

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.contentType = [aDecoder decodeObjectForKey:ContentTypeKey];
        self.contentLength = [aDecoder decodeObjectForKey:ContentLengthKey];
        self.byteRangeAccessSupported = [aDecoder decodeBoolForKey:ByteRangeAccessSupportedKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.contentType forKey:ContentTypeKey];
    [aCoder encodeObject:self.contentLength forKey:ContentLengthKey];
    [aCoder encodeBool:self.byteRangeAccessSupported forKey:ByteRangeAccessSupportedKey];
}

@end
