//
//  MResourceDataCreator.h
//  MResourceDemo
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MResourceCacher.h"

@protocol MResourceCreateDataDelegate;
@class MResourceContentInfo;

@interface MResourceDataCreator : NSObject

@property (nonatomic, strong) MResourceCacher *cacher;

@property (nonatomic, weak) id<MResourceCreateDataDelegate> delegate;

- (instancetype)initWithURL:(NSURL*)url;

- (void)startCreateDataInRange:(MRRange)range;

- (void)stop;

@end

@protocol MResourceCreateDataDelegate <NSObject>

- (void)dataCreator:(MResourceDataCreator*)creator didCreateContentInfo:(MResourceContentInfo*)info;

- (void)dataCreator:(MResourceDataCreator *)creator didCreateData:(NSData *)data;

- (void)dataCreator:(MResourceDataCreator *)creator didFinishWithError:(NSError*)error;

@end
