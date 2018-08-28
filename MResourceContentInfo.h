//
//  MResourceContentInfo.h
//  MResourceDemo
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MResourceContentInfo : NSObject <NSCoding>

@property (nonatomic, copy) NSString *contentType;

@property (nonatomic, copy) NSString *contentLength;

@property (nonatomic, assign) BOOL byteRangeAccessSupported;

@end
