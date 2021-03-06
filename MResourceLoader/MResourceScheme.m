//
//  MResourceScheme.m
//  MResourceLoader
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "MResourceScheme.h"

NSString * const MResourceSchemePrefix = @"__MResourceScheme__:";

@implementation MResourceScheme

+ (NSURL*)mrSchemeURL:(NSURL*)url {
    if (!url) { return nil;}
    return [NSURL URLWithString:[MResourceSchemePrefix stringByAppendingString:[url absoluteString]]];
}

+ (NSURL*)originURL:(NSURL*)url {
    if ([url.absoluteString hasPrefix:MResourceSchemePrefix]) {
        NSString *urlStr = [url.absoluteString substringFromIndex:MResourceSchemePrefix.length];
        return [NSURL URLWithString:urlStr];
    }
    return nil;
}

@end
