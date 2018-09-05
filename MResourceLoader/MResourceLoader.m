//
//  MResourceLoader.m
//  MResourceLoader
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "MResourceLoader.h"
#import "MResourceDataFiller.h"
#import "MResourceCacher.h"

@interface MResourceLoader()
@property (nonatomic, strong) NSMutableDictionary *pendingLoaders;
@property (nonatomic, strong) MResourceCacher *cacher;
@end

@implementation MResourceLoader

#pragma mark - AVAssetResourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest NS_AVAILABLE(10_9, 6_0) {
    MRLog(@"new loadingRequest: %@",loadingRequest);
    NSURL *url = [MResourceScheme originURL:loadingRequest.request.URL];
    MRAsset(url, @"Error: resourloader url is nil!", NO);
    MResourceDataFiller *dataFiller = [self _dataFillerForLoadRequest:loadingRequest];
    [dataFiller start];
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest NS_AVAILABLE(10_9, 7_0) {
    MRLog(@"system cancel loadingRequest: %@",loadingRequest);
    MResourceDataFiller *dataFiller = [self _dataFillerForLoadRequest:loadingRequest];
    [dataFiller cancel];
    [self.pendingLoaders removeObjectForKey:@(loadingRequest.hash)];
}

- (MResourceDataFiller*)_dataFillerForLoadRequest:(AVAssetResourceLoadingRequest*)loadRequest {
    MResourceDataFiller *filler = [self.pendingLoaders objectForKey:@(loadRequest.hash)];
    if (!filler) {
        filler = [[MResourceDataFiller alloc] initWithLoadingRequest:loadRequest];
        [self.pendingLoaders setObject:filler forKey:@(loadRequest.hash)];
    }
    return filler;
}

#pragma mark - Get Method
- (NSMutableDictionary*)pendingLoaders {
    if (!_pendingLoaders) {
        _pendingLoaders = [NSMutableDictionary dictionary];
    }
    return _pendingLoaders;
}
@end
