//
//  MResourceLoaderManager.h
//  MResourceLoader
//
//  Created by MiaoChao on 2018/8/27.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

@interface MResourceCacheManager : NSObject

/**
 @abstract default is 'sandbox directory'/Documents/MResourceCache
 @discussion cachePath is cache file's root path.
 every url resource has a sub folder in cachePath.
 setFolderPath: can change it
 @result all cache file's root directory
 */
@property (nonatomic, copy, readonly) NSString *cachePath;

/**
 @abstract Returns the current amount of space consumed by the
 on-disk cache of all cache file.
 @discussion This size, measured in bytes, indicates the current
 usage of the on-disk cache.
 @result the current usage of the on-disk cache of all cache file.
 */
@property (nonatomic, assign, readonly) NSUInteger currentDiskUsage;

+ (instancetype)defaultManager;

/**
 Set video cache folder path, this will change cachePath;
 filePath must be absoult path, cachePath is append "MResourceCache" in filePath end
 
 @param filePath relative path
 */
- (void)setFolderPath:(NSString*)filePath;

- (BOOL)clearAllCache;

- (BOOL)clearCacheForURL:(NSString*)url;

@end
