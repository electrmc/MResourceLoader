//
//  MResourceLoaderManager.h
//  MResourceDemo
//
//  Created by MiaoChao on 2018/8/27.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MResourceCacheManager : NSObject

@property (nonatomic, copy, readonly) NSString *cachePath;

@property (nonatomic, assign, readonly) NSUInteger currentDiskUsage;

+ (instancetype)defaultManager;

- (void)setFolderPath:(NSString*)filePath;

- (BOOL)clearAllCache;

- (BOOL)clearCacheForURL:(NSString*)url;

@end
