//
//  MResourceDataFiller.h
//  MResourceDemo
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MResourceCacher.h"
#import "MResourceDataCreator.h"

@interface MResourceDataFiller : NSObject <MResourceCreateDataDelegate>

- (instancetype)initWithLoadingRequest:(AVAssetResourceLoadingRequest*)loadingRequest;

- (void)start;

- (void)cancel;

@end
