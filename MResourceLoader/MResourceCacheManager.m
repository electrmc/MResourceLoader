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
@property (nonatomic, strong) NSHashTable *handlerSet;
@end

@implementation MResourceCacheManager

+ (instancetype)defaultManager {
    static MResourceCacheManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance setFolderPath:[NSHomeDirectory() stringByAppendingString:RelativeFilePath]];
        instance.handlerSet = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:0];
    });
    return instance;
}

- (void)setFolderPath:(NSString*)filePath {
    if (!filePath) {
        return;
    }
    _cachePath = [filePath stringByAppendingPathComponent:ResourceCacheDirName];
}

- (void)registerFileHandler:(id<MResourceCacheFileManagerDelegate>)fileHandler {
    if (!fileHandler) {
        return;
    }
    [self.handlerSet addObject:fileHandler];
}

- (void)unregisterFileHandler:(id<MResourceCacheFileManagerDelegate>)fileHandler {
    [self.handlerSet removeObject:fileHandler];
}

- (BOOL)clearInvalidCache {
    NSArray<NSString *> *resourceKeys = @[NSURLIsDirectoryKey,
                                          NSURLContentAccessDateKey,
                                          NSURLContentModificationDateKey];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [NSURL fileURLWithPath:self.cachePath];
    
    NSArray<NSURL*> *fileUrls = [fileManager contentsOfDirectoryAtURL:url
                                           includingPropertiesForKeys:resourceKeys
                                                              options:0
                                                                error:NULL];
    
    NSMutableArray<NSString*> *timestamps = [NSMutableArray array];
    NSMutableDictionary *deleteFiles = [NSMutableDictionary dictionary];
    NSMutableArray *expireFiles = [NSMutableArray array];
    
    NSTimeInterval nowdate = [[NSDate date] timeIntervalSinceReferenceDate];
    
    NSUInteger deleteFileCount = fileUrls.count / 3;
    deleteFileCount  = deleteFileCount < 1 ? 1 : deleteFileCount;
    
    for (NSURL *fileURL in fileUrls) {
        
        NSError *error;
        NSDictionary<NSString *, id> *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:&error];
        
        // Skip files and errors.
        if (error || !resourceValues || ![resourceValues[NSURLIsDirectoryKey] boolValue]) {
            continue;
        }
        
        NSDate *modifyDate = [resourceValues objectForKey:NSURLContentModificationDateKey];
        NSTimeInterval filetimestamp = modifyDate.timeIntervalSinceReferenceDate;
        
        if (self.maxCacheAge > 0 && nowdate - filetimestamp > self.maxCacheAge) {
            [expireFiles addObject:fileURL];
        }
        
        if (expireFiles.count > deleteFileCount) {
            [timestamps removeAllObjects];
            [deleteFiles removeAllObjects];
            continue;
        }
        
        NSString *key = [NSString stringWithFormat:@"%f",filetimestamp];
        NSInteger index = [self _insertSort:timestamps object:key];
        [timestamps insertObject:key atIndex:index];
        [deleteFiles setObject:fileURL forKey:key];
    }
    
    BOOL deletedFile = NO;
    for (NSString *filepath in expireFiles) {
        deletedFile = deletedFile || [self _deleteFileForPath:filepath];
    }
    
    for (int i=0; i<timestamps.count && i < deleteFileCount; i++) {
        NSString *key = timestamps[i];
        NSString *filepath = [deleteFiles objectForKey:key];
        deletedFile = deletedFile || [self _deleteFileForPath:filepath];
    }
    
    return deletedFile;
}

- (BOOL)clearAllCache {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [NSURL fileURLWithPath:self.cachePath];
    
    NSArray<NSURL*> *fileUrls = [fileManager contentsOfDirectoryAtURL:url
                                           includingPropertiesForKeys:nil
                                                              options:0
                                                                error:NULL];
    BOOL deletedFile = NO;
    for (NSString *url in fileUrls) {
        deletedFile = deletedFile || [self _deleteFileForPath:url];
    }
    return deletedFile;
}

- (BOOL)clearCacheForURL:(NSString*)url; {
    if (!url) {
        return NO;
    }
    
    NSString *key = [url mr_md5];
    NSString *path = [self.cachePath stringByAppendingPathComponent:key];
    return [self _deleteFileForPath:path];
}

- (NSUInteger)currentDiskUsage {
    return [self _readFolderPath:self.cachePath];
}

- (NSInteger)_insertSort:(NSMutableArray<NSString*>*)sortedAry object:(NSString*)obj {
    if (sortedAry.count < 1) {
        return 0;
    }
    
    int iBegin = 0;
    int iEnd = (int)sortedAry.count - 1;
    int index = -1;
    while (iBegin <= iEnd) {
        index = (iBegin + iEnd) / 2;
        if (sortedAry[index].floatValue > obj.floatValue ) {
            iEnd = index - 1;
        } else {
            iBegin = index + 1;
        }
    }
    
    if (sortedAry[index].floatValue <= obj.floatValue) {
        index++;
    }
    
    return index;
}

- (BOOL)_deleteFileForPath:(NSString*)filePath {
    MRAsset(filePath, @"Error : file path is nil", NO);
    BOOL shouldDelete = [self _shouldDeleteFile:filePath];
    if (!shouldDelete) {
        return NO;
    }
    
    NSLock *lock = [MResourceFileLock fileIDManager].fileLock;
    [lock lock];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL suc = [fileManager removeItemAtPath:filePath error:&error];
    if (!suc || error) {
        MRLog(@"delet cache : %@",error);
    }
    [lock unlock];
    return suc;
}

- (BOOL)_shouldDeleteFile:(NSString*)filePath {
    if (!filePath) {
        return NO;
    }
    for (id<MResourceCacheFileManagerDelegate>delegate in self.handlerSet) {
        if ([delegate respondsToSelector:@selector(shouldDeleteFileInPath:)]) {
            if (![delegate shouldDeleteFileInPath:filePath]) {
                return NO;
            }
        }
    }
    return YES;
}

- (NSUInteger)_readFolderPath:(NSString*)folderPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:folderPath];
    if (isExist){
        NSEnumerator *childFileEnumerator = [[fileManager subpathsAtPath:folderPath] objectEnumerator];
        NSUInteger folderSize = 0;
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
