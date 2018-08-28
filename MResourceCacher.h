//
//  MResourceCacher.h
//  MResourceDemo
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MResourceUtility.h"
#import "MResourceContentInfo.h"

@interface MResourceCacher : NSObject

@property (nonatomic, strong, readonly) MResourceContentInfo *contentInfo;

@property (nonatomic, copy) NSString *cachePath;

- (instancetype)initWithURL:(NSURL*)url;

- (void)cacheContentInfo:(MResourceContentInfo*)info;

- (MRRange)localDataRangeForRange:(MRRange)fillDataRange;

- (void)setCacheData:(NSData*)data range:(MRRange)range error:(NSError**)error;

- (NSData*)cacheDataWithRange:(MRRange)range error:(NSError**)error;

@end
