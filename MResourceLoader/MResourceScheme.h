//
//  MResourceScheme.h
//  MResourceLoader
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

extern NSString * const MResourceSchemePrefix;

@interface MResourceScheme : NSObject

+ (NSURL*)mrSchemeURL:(NSURL*)url;

+ (NSURL*)originURL:(NSURL*)url;

@end
