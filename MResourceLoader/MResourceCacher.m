//
//  MResourceCacher.m
//  MResourceDemo
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//

#import "MResourceCacher.h"
#import "MResourceFileHandler.h"
#import "NSString+MRResourceUtility.h"

@interface MResourceCacher()
@property (nonatomic, strong) MResourceFileHandler *fileHandler;
@property (nonatomic, strong) NSMutableArray<NSString*>*ranges;
@end

@implementation MResourceCacher

- (instancetype)initWithURL:(NSURL*)url {
    self = [super init];
    if (self) {
        self.fileHandler = [[MResourceFileHandler alloc] initWithResourceID:url];
        _contentInfo = self.fileHandler.contentInfo;
        self.ranges = [NSMutableArray arrayWithArray:self.fileHandler.ranges];
    }
    return self;
}

- (void)cacheContentInfo:(MResourceContentInfo*)info {
    if (_contentInfo == info) {
        return;
    }
    _contentInfo = info;
    [self.fileHandler saveContentInfo:info];
}

- (MRRange)localDataRangeForRange:(MRRange)fillDataRange {
    if (fillDataRange.length == 0) {
        return fillDataRange;
    }
    
    for (int i=0; i<self.ranges.count; i++) {
        MRRange range = [self.ranges[i] MRRange];
        if (range.location == MRRANGE_UNDEFINE &&
            range.length == MRRANGE_UNDEFINE) {
            NSAssert(0, @"Error : Cacher ranges is error");
            continue;
        }
        if (MRMaxRange(fillDataRange) > range.location &&
            MRMaxRange(range) > fillDataRange.location) {
            MRLong location = MAX(fillDataRange.location, range.location);
            MRLong offset = MIN(MRMaxRange(fillDataRange), MRMaxRange(range));
            return MRMakeRange(location, offset - location);
        }
    }
    return MRMakeRange(0, 0);
}

- (void)setCacheData:(NSData*)data range:(MRRange)range error:(NSError**)error {
    if (data.length != range.length) {
        NSAssert(0, @"Error : cache data length is error");
        return;
    }
    BOOL suc = [self.fileHandler writeData:data range:range error:error];
    if (suc) {
        [self _insetRange:range];
        [self.fileHandler saveRanges:self.ranges];
    }
}

- (NSData*)cacheDataWithRange:(MRRange)range error:(NSError**)error {
    return [self.fileHandler readDataForRange:range error:error];
}

- (void)_insetRange:(MRRange)range {
    if (range.length == 0) {
        return;
    }
    NSUInteger count=0;
    while (count < self.ranges.count) {
        MRRange rangeTemp = [self.ranges[count] MRRange];
        if (rangeTemp.location == MRRANGE_UNDEFINE && rangeTemp.length == MRRANGE_UNDEFINE) {
            NSAssert(0, @"Error : cacher insert range error");
            return;
        }
        if (rangeTemp.location > range.location) {
            break;
        }
        count++;
    }
    
    [self.ranges insertObject:[NSString stringFromRange:range] atIndex:count];
    
    for (int i=0; i<self.ranges.count; i++) {
        MRRange minRange = [self.ranges[i] MRRange];
        MRRange maxRange = MRMakeRange(0, 0);
        if (self.ranges.count > i+1) {
            maxRange = [self.ranges[i+1] MRRange];
        } else {
            break;
        }
        
        if (MRMaxRange(minRange) >= maxRange.location && maxRange.length > 0) {
            MRLong  location = MIN(minRange.location, maxRange.location);
            MRLong  offset = MAX(MRMaxRange(minRange), MRMaxRange(maxRange));
            MRLong length = offset - location;
            MRRange mergeRange = MRMakeRange(location, (NSUInteger)length);
            [self.ranges replaceObjectAtIndex:i withObject:[NSString stringFromRange:mergeRange]];
            [self.ranges removeObjectAtIndex:i+1];
            i--;
        }
    }
}

@end
