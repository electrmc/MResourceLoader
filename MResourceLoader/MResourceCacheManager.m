//
//  MResourceLoaderManager.m
//  MResourceLoader
//
//  Created by MiaoChao on 2018/8/27.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "MResourceCacheManager.h"
#import "NSString+MRResourceUtility.h"
#import "MResourceUtility.h"
#import "MResourceFileHandler.h"

static NSString * const RelativeFilePath = @"/Documents";
static NSString * const ResourceCacheDirName = @"/MResourceCache/";

@interface MResourceCacheManager()

@end

@implementation MResourceCacheManager

+ (instancetype)defaultManager {
    static MResourceCacheManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance setFolderPath:[NSHomeDirectory() stringByAppendingString:RelativeFilePath]];
    });
    return instance;
}

- (void)setFolderPath:(NSString*)filePath {
    if (!filePath) {
        return;
    }
    _cachePath = [filePath stringByAppendingPathComponent:ResourceCacheDirName];
}

- (BOOL)clearAllCache {
    NSLock *lock = [MResourceFileLock fileIDManager].fileLock;
    [lock lock];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL suc = [fileManager removeItemAtPath:self.cachePath error:&error];
    if (!suc) {
        MRLog(@"delete cache file : %@",error);
    }
    [lock unlock];
    return suc;
}

- (BOOL)clearCacheForURL:(NSString*)url; {
    if (!url) {
        return NO;
    }
    NSLock *lock = [MResourceFileLock fileIDManager].fileLock;
    [lock lock];
    NSString *key = [url mr_md5];
    NSString *path = [self.cachePath stringByAppendingPathComponent:key];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL suc = [fileManager removeItemAtPath:path error:&error];
    if (!suc || error) {
        MRLog(@"delet cache : %@",error);
    }
    [lock unlock];
    return suc;
}

- (NSUInteger)currentDiskUsage {
    return [self _readFolderPath:self.cachePath];
}

- (NSUInteger)_readFolderPath:(NSString*)folderPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:folderPath];
    if (isExist){
        NSEnumerator *childFileEnumerator = [[fileManager subpathsAtPath:folderPath] objectEnumerator];
        unsigned long long folderSize = 0;
        NSString *fileName = @"";
        while ((fileName = [childFileEnumerator nextObject]) != nil){
            NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
            folderSize += [self _fileSizeAtPath:fileAbsolutePath];
        }
        return folderSize;
    } else {
        MRLog(@"file is not exist");
        return 0;
    }
}

- (unsigned long long)_fileSizeAtPath:(NSString *)filePath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:filePath];
    if (isExist){
        unsigned long long fileSize = [[fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
        return fileSize;
    } else {
        MRLog(@"file is not exist");
        return 0;
    }
}
@end
