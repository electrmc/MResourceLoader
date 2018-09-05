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

@protocol MResourceCacheFileManagerDelegate <NSObject>
- (BOOL)shouldDeleteFileInPath:(NSString*)filePath;
@end

@interface MResourceCacheManager : NSObject
/**
 'cachePath' is cache folder root path. Every url's resource has a sub folder in cachePath.
 'setFolderPath:' can change it.
 Default is 'sandbox directory'/Documents/MResourceCache
 */
@property (nonatomic, copy, readonly) NSString *cachePath;

/**
 Returns the current amount of space consumed by the on-disk cache of all cache file.
 This size, measured in bytes.
 */
@property (nonatomic, assign, readonly) NSUInteger currentDiskUsage;

/**
 Returns the maxDiskUsage, This size, measured in bytes.
 Change 'maxDiskUsage' can trigger 'clearInvalidCache'
 */
@property (nonatomic, assign) NSUInteger maxDiskUsage;

/**
 The maximum length of time to keep an file in the disk cache, in seconds.
 Setting this to a negative value means no expiring.
 Setting this to zero means that all cached files would be removed when do expiration check.
 Defaults to 1 weak.
 */
@property (assign, nonatomic) NSTimeInterval maxCacheAge;

+ (instancetype)defaultManager;

- (void)registerFileHandler:(id<MResourceCacheFileManagerDelegate>)fileHandler;

- (void)unregisterFileHandler:(id<MResourceCacheFileManagerDelegate>)fileHandler;;

/**
 Set video cache folder path, this will change cachePath;
 filePath must be absoult path, cachePath is append "MResourceCache" in filePath end
 
 @param filePath relative path
 */
- (void)setFolderPath:(NSString*)filePath;

/**
 If diskusage exceed maxDiskUsage, this method will clear older cache file.
 The using file cannot be deleted.
 @return if clear file return YES, otherwise return NO
 */
- (BOOL)clearOlderCache;

/**
 This method will clear all cache file.
 The using file cannot be deleted.
 @return if clear file return YES, otherwise return NO
 */
- (BOOL)clearAllCache;

/**
 Delete cache file for url.
 The using file cannot be deleted.
 @return if clear file return YES, otherwise return NO
 */
- (BOOL)clearCacheForURL:(NSString*)url;
@end
