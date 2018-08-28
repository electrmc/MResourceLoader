//
//  MResourceSessionManager.h
//  MResourceDemo
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MResourceDataFetcher;

@interface MResourceSessionManager : NSObject

@property (nonatomic, strong, readonly) NSURLSession *session;

+ (instancetype)shareSession;

- (void)setDelegate:(id<NSURLSessionDataDelegate>)deleate forTask:(NSURLSessionDataTask*)task;

@end
