//
//  MResourceScheme.h
//  MResourceDemo
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MResourceScheme : NSObject

+ (NSURL*)mrSchemeURL:(NSURL*)url;

+ (NSURL*)originURL:(NSURL*)url;

@end
