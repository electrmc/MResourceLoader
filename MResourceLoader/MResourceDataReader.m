//
//  MResourceDataReader.m
//  MResourceLoader
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "MResourceDataReader.h"

static NSUInteger MaxDataFragmentLength = 204800;

@interface MResourceDataReader()
@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, assign, readonly) MRRange originRange;
@property (nonatomic, assign) MRLong currentOffset;
@property (atomic, assign) BOOL stopRead;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation MResourceDataReader

- (void)dealloc {
    [self.operationQueue cancelAllOperations];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super initWithURL:url];
    if (self) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)startCreateDataInRange:(MRRange)range {
    [self stop];
    
    _originRange = range;
    self.stopRead = NO;
    self.currentOffset = range.location;
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(_readData) object:nil];
    [self.operationQueue addOperation:operation];
}

- (void)stop {
    self.stopRead = YES;
    [self.operationQueue cancelAllOperations];
}

- (void)_readData {
    if (self.cacher.contentInfo) {
        if ([self.delegate respondsToSelector:@selector(dataCreator:didCreateContentInfo:)]) {
            [self.delegate dataCreator:self didCreateContentInfo:self.cacher.contentInfo];
        }
    } else {
        [self _finishWithError:nil];
        return;
    }
    
    while (self.currentOffset < MRMaxRange(self.originRange) && !self.stopRead) {
        NSUInteger unreadDataLength = 0;
        if (self.currentOffset + MaxDataFragmentLength > MRMaxRange(self.originRange)) {
            unreadDataLength = (NSUInteger)(MRMaxRange(self.originRange) - self.currentOffset);
        } else {
            unreadDataLength = MaxDataFragmentLength;
        }
        NSError *error = nil;
        NSData *data = [self.cacher cacheDataWithRange:MRMakeRange(self.currentOffset, unreadDataLength) error:&error];
        if (data.length != unreadDataLength) {
            NSAssert(0, @"Error : data reader read data length is unexpected");
            [self _finishWithError:error];
        }
        MRLog(@"did read data : %ld",data.length);
        if ([self.delegate respondsToSelector:@selector(dataCreator:didCreateData:)]) {
            [self.delegate dataCreator:self didCreateData:data];
        }
        self.currentOffset += unreadDataLength;
    }
    [self _finishWithError:nil];
}

- (void)_finishWithError:(NSError*)error {
    if ([self.delegate respondsToSelector:@selector(dataCreator:didFinishWithError:)]) {
        [self.delegate dataCreator:self didFinishWithError:error];
    }
}

@end
