//
//  MResourceDataFiller.m
//  MResourceDemo
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//

#import "MResourceDataFiller.h"
#import "MResourceDataReader.h"
#import "MResourceDataFetcher.h"
#import "MResourceContentInfo.h"
#import "MResourceScheme.h"

@interface MResourceDataFiller()
@property (nonatomic, strong) NSMutableArray<MResourceDataCreator*> *pendingDataCreators;
@property (nonatomic, strong, readonly) AVAssetResourceLoadingRequest *loadingRequest;
@property (nonatomic, strong) MResourceCacher *cacher;
@end

@implementation MResourceDataFiller

- (void)dealloc {
    [self.pendingDataCreators enumerateObjectsUsingBlock:^(MResourceDataCreator * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj stop];
    }];
}

- (instancetype)initWithLoadingRequest:(AVAssetResourceLoadingRequest*)loadingRequest {
    self = [super init];
    if (self) {
        _loadingRequest = loadingRequest;
    }
    return self;
}

- (void)start {
    [self _continueFillData];
}

- (void)cancel {
    [self _finishFillWithError:nil];
}

- (void)_continueFillData {
    AVAssetResourceLoadingDataRequest *dataRequest = self.loadingRequest.dataRequest;
    MRLong currentOffset = dataRequest.currentOffset;
    if (currentOffset >= dataRequest.requestedOffset + dataRequest.requestedLength) {
        [self _finishFillWithError:nil];
        return;
    }
    
    NSUInteger expectDataLength = dataRequest.requestedLength - (dataRequest.currentOffset - dataRequest.requestedOffset);
    MRRange expectDataRange = MRMakeRange(currentOffset, expectDataLength);
    
    if (!self.cacher.contentInfo) {
        [self _fetchDataFromRemote:expectDataRange];
        return;
    }
    
    MRRange localDataRange = [self.cacher localDataRangeForRange:expectDataRange];
    if (localDataRange.length > 0) {
        if (localDataRange.location == expectDataRange.location) {
            [self _readDataFromLocal:localDataRange];
        } else {
            MRRange dataFragment = MRMakeRange(currentOffset, localDataRange.location - expectDataRange.location);
            [self _fetchDataFromRemote:dataFragment];
        }
    } else {
        [self _fetchDataFromRemote:expectDataRange];
    }
}

- (void)_readDataFromLocal:(MRRange)range {
    if (range.length < 1) {
        return;
    }
    NSURL *url = [MResourceScheme originURL:self.loadingRequest.request.URL];
    MResourceDataReader *reader = [[MResourceDataReader alloc] initWithURL:url];
    reader.delegate = self;
    reader.cacher = self.cacher;
    [self.pendingDataCreators addObject:reader];
    [reader startCreateDataInRange:range];
}

- (void)_fetchDataFromRemote:(MRRange)range {
    if (range.length < 1) {
        return;
    }
    NSURL *url = [MResourceScheme originURL:self.loadingRequest.request.URL];
    MResourceDataFetcher *fetcher = [[MResourceDataFetcher alloc] initWithURL:url];
    fetcher.delegate = self;
    fetcher.cacher = self.cacher;
    [self.pendingDataCreators addObject:fetcher];
    [fetcher startCreateDataInRange:range];
}

- (void)_fullfillContentInfo:(MResourceContentInfo*)contentInfo {
    AVAssetResourceLoadingContentInformationRequest *contentInformationRequest = self.loadingRequest.contentInformationRequest;
    if (contentInfo && contentInformationRequest &&
        !contentInformationRequest.contentType) {
        
        // Fullfill content information
        contentInformationRequest.contentType = contentInfo.contentType;
        contentInformationRequest.contentLength = [contentInfo.contentLength longLongValue];
        contentInformationRequest.byteRangeAccessSupported = contentInfo.byteRangeAccessSupported;
        [self.cacher cacheContentInfo:contentInfo];
        MRLog(@"did fill content info : %lld",contentInformationRequest.contentLength);
    }
}

- (void)_finishFillWithError:(NSError*)error {
    MRLog(@"loadingRequest finish : %ld",self.loadingRequest);
    if (self.loadingRequest.isFinished) {
        return;
    }
    if (error) {
        [self.loadingRequest finishLoadingWithError:error];
    } else {
        [self.loadingRequest finishLoading];
    }
}

#pragma mark - MResourceCreateDataDelegate
- (void)dataCreator:(MResourceDataCreator*)creator didCreateContentInfo:(MResourceContentInfo*)info {
    [self _fullfillContentInfo:info];
}

- (void)dataCreator:(MResourceDataCreator *)creator didCreateData:(NSData *)data {
    MRLog(@"fill data length : %ld",data.length);
    if (data.length > 0) {
        [self.loadingRequest.dataRequest respondWithData:data];
    }
}

- (void)dataCreator:(MResourceDataCreator *)creator didFinishWithError:(NSError*)error {
    [creator stop];
    [self.pendingDataCreators removeObject:creator];
    
    if (error) {
        [self _finishFillWithError:error];
    } else {
        [self _continueFillData];
    }
}

#pragma mark - pendingDataCreators
- (NSMutableArray*)pendingDataCreators {
    if (!_pendingDataCreators) {
        _pendingDataCreators = [NSMutableArray array];
    }
    return _pendingDataCreators;
}

- (MResourceCacher*)cacher {
    if (!_cacher) {
        NSURL *originUrl = [MResourceScheme originURL:self.loadingRequest.request.URL];
        _cacher = [[MResourceCacher alloc] initWithURL:originUrl];
    }
    return _cacher;
}
@end
