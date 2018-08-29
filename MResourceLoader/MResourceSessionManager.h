//
//  MResourceSessionManager.h
//  MResourceLoader
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

@class MResourceDataFetcher;

@interface MResourceSessionManager : NSObject

@property (nonatomic, strong, readonly) NSURLSession *session;

+ (instancetype)shareSession;

- (void)setDelegate:(id<NSURLSessionDataDelegate>)deleate forTask:(NSURLSessionDataTask*)task;

@end
