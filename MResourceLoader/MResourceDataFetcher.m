//
//  MResourceDataFetcher.m
//  MResourceLoader
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "MResourceDataFetcher.h"
#import "MResourceSessionManager.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface MResourceDataFetcher()
@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, assign, readonly) MRRange originRange;
@property (nonatomic, assign) MRLong currentOffset;
@property (nonatomic, strong) NSMutableData *receiveData;
@end

@implementation MResourceDataFetcher

- (void)dealloc {
    [self stop];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _url = url;
    }
    return self;
}

- (void)startCreateDataInRange:(MRRange)range {
    MRLog(@"fetcher start : %lu range : %lld , %lu",(unsigned long)self.hash,range.location,(unsigned long)range.length);
    _originRange = range;
    self.currentOffset = range.location;
    MResourceSessionManager *sessionManager = [MResourceSessionManager shareSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
    request.timeoutInterval = 10.f;
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    if (range.length > 0) {
        [request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld",(unsigned long)range.location, (unsigned long)MRMaxRange(range)] forHTTPHeaderField:@"Range"];
    }
    [self.dataTask cancel];
    self.receiveData = [NSMutableData data];
    _dataTask = [sessionManager.session dataTaskWithRequest:request];
    [sessionManager setDelegate:self forTask:self.dataTask];
    [self.dataTask resume];
}

- (void)stop {
    if (self.dataTask.state != NSURLSessionTaskStateCanceling &&
        self.dataTask.state != NSURLSessionTaskStateCompleted) {
        [self.dataTask cancel];
    }
}

- (MResourceContentInfo*)_contentInfoWithResponse:(NSURLResponse*)response {
    if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        return nil;
    }
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSDictionary *dic = (NSDictionary *)[httpResponse allHeaderFields] ;
    NSString *content = [dic valueForKey:@"Content-Range"];
    NSArray *array = [content componentsSeparatedByString:@"/"];
    NSString *length = array.lastObject;
    
    NSUInteger videoLength;
    
    if ([length integerValue] == 0) {
        videoLength = (NSUInteger)httpResponse.expectedContentLength;
    } else {
        videoLength = [length integerValue];
    }
    
    NSString *mimeType = response.MIMEType;
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
    
    if ([mimeType rangeOfString:@"video/"].location == NSNotFound &&
        [mimeType rangeOfString:@"audio/"].location == NSNotFound &&
        [mimeType rangeOfString:@"application"].location == NSNotFound) {
        return nil;
    }
    
    MResourceContentInfo *info=  [[MResourceContentInfo alloc]init];
    info.contentLength = [NSString stringWithFormat:@"%lu",(unsigned long)videoLength];
    info.contentType = CFBridgingRelease(contentType);
    info.byteRangeAccessSupported = YES;
    return info;
}

- (NSData*)_getFillDataWithResponseData:(NSData*)data{
    if (data) {
        [self.receiveData appendData:data];
    }
    
    if (self.currentOffset >= MRMaxRange(self.originRange)) {
        return nil;
    }
    
    NSUInteger expectDataLength = MRMaxRange(self.originRange) - self.currentOffset;
    NSUInteger unreadDataLength = MIN(self.receiveData.length, expectDataLength);
    NSRange range = NSMakeRange(0, unreadDataLength);
    NSData *reslutData = [self.receiveData subdataWithRange:range];
    NSError *error = nil;
    [self.cacher setCacheData:reslutData range:MRMakeRange(self.currentOffset, unreadDataLength) error:&error];
    NSAssert(!error, @"Error : fetcher cache data error");
    self.currentOffset += unreadDataLength;
    [self.receiveData replaceBytesInRange:range withBytes:NULL length:0];
    return reslutData;
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    if (self.receiveData.length > 0) {
        NSLog(@"fetcher currentOffset : %lld, remained data  length : %ld",self.currentOffset, self.receiveData.length);
        NSError *cacheerror = nil;
        [self.cacher setCacheData:self.receiveData
                            range:MRMakeRange(self.currentOffset, self.receiveData.length)
                            error:&cacheerror];
        
        NSAssert(!cacheerror,@"Error : fetcher cache data error on finish");
    }
    if ([self.delegate respondsToSelector:@selector(dataCreator:didFinishWithError:)]) {
        [self.delegate dataCreator:self didFinishWithError:error];
    }
}

#pragma mark - NSURLSessionDataDelegat
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {

    MResourceContentInfo *info = [self _contentInfoWithResponse:response];
    if (!info) {
        if ([self.delegate respondsToSelector:@selector(dataCreator:didFinishWithError:)]) {
            [self.delegate dataCreator:self didFinishWithError:nil];
        }
        completionHandler(NSURLSessionResponseCancel);
    } else {
        if ([self.delegate respondsToSelector:@selector(dataCreator:didCreateContentInfo:)]) {
            [self.delegate dataCreator:self didCreateContentInfo:info];
        }
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    NSData *fillDataFragment = [self _getFillDataWithResponseData:data];
    if (fillDataFragment.length > 0) {
        if ([self.delegate respondsToSelector:@selector(dataCreator:didCreateData:)]) {
            [self.delegate dataCreator:self didCreateData:fillDataFragment];
        }
    }
    
    if (self.currentOffset >= MRMaxRange(self.originRange)) {
        if ([self.delegate respondsToSelector:@selector(dataCreator:didFinishWithError:)]) {
            [self.delegate dataCreator:self didFinishWithError:nil];
        }
    }
}
@end
