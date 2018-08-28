//
//  MResourceDataFetcher.h
//  MResourceDemo
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//

#import "MResourceDataCreator.h"

@interface MResourceDataFetcher : MResourceDataCreator <NSURLSessionDataDelegate>
@property (nonatomic, strong, readonly) NSURLSessionDataTask *dataTask;
@end
