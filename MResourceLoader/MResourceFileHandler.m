//
//  MResourceFileHandler.m
//  MResourceLoader
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "MResourceFileHandler.h"
#import "NSString+MRResourceUtility.h"
#import "MResourceCacheManager.h"

static NSString * const VideoCacheFile = @"videoCacheFile";
static NSString * const ContentInfoCacheFile = @"ContentInfoCacheFile";
static NSString * const RangesCacheFile = @"RangesCacheFile";

@implementation MResourceFileLock
+ (instancetype)fileIDManager {
    static MResourceFileLock *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MResourceFileLock alloc] init];
    });
    return instance;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _fileLock = [[NSLock alloc] init];
    }
    return self;
}
@end

@interface MResourceFileHandler()
@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSLock *lock;

@property (nonatomic, copy, readonly) NSString *folderPath;
@property (nonatomic, strong) NSFileHandle *fileReader;
@property (nonatomic, strong) NSFileHandle *fileWriter;
@property (nonatomic, copy) NSString *videoFilePath;
@property (nonatomic, copy) NSString *contentInfoPath;
@property (nonatomic, copy) NSString *rangesPath;
@end

@implementation MResourceFileHandler

- (instancetype)initWithResourceID:(NSURL*)url {
    self = [super init];
    if (self) {
        _url = url;
        _lock = [[MResourceFileLock fileIDManager] fileLock];
        NSString *tempFolder = [[MResourceCacheManager defaultManager] cachePath];
        _folderPath = [tempFolder stringByAppendingPathComponent:[url.absoluteString mr_md5]];
        [self _configFileHandler];
        [self _unarchiveInfo];
    }
    return self;
}

- (BOOL)saveContentInfo:(MResourceContentInfo*)contentInfo {
    if ([self.lock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]]) {
        [NSKeyedArchiver archiveRootObject:contentInfo toFile:self.contentInfoPath];
        [self.lock unlock];
        return YES;
    }
    return NO;
}

- (BOOL)saveRanges:(NSArray<NSString*>*)ranges {
    if ([self.lock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]]) {
        [NSKeyedArchiver archiveRootObject:ranges toFile:self.rangesPath];
        [self.lock unlock];
        return YES;
    }
    return NO;
}

- (BOOL)writeData:(NSData*)data range:(MRRange)range error:(NSError**)error {
    if ([self.lock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]]) {
        @try {
            [self.fileWriter seekToFileOffset:range.location];
            [self.fileWriter writeData:data];
            [self.lock unlock];
            return YES;
        } @catch (NSException *exception) {
            *error = [NSError errorWithDomain:exception.name code:10012 userInfo:@{NSLocalizedDescriptionKey: exception.reason, @"exception": exception}];
        }
        [self.lock unlock];
        return NO;
    } else {
        return NO;
    }
}

- (NSData*)readDataForRange:(MRRange)range error:(NSError**)error {
    if ([self.lock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:3.0]]) {
        @try {
            [self.fileReader seekToFileOffset:range.location];
            NSData *data = [self.fileReader readDataOfLength:range.length]; // 空数据也会返回，所以如果 range 错误，会导致播放失效
            [self.lock unlock];
            return data;
        } @catch (NSException *exception) {
            *error = [NSError errorWithDomain:exception.name code:10011 userInfo:@{NSLocalizedDescriptionKey: exception.reason, @"exception": exception}];
        }
        [self.lock unlock];
        return nil;
    } else {
        return nil;
    }
}

- (void)_configFileHandler {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *cacheFolder = [self.videoFilePath stringByDeletingLastPathComponent];
    if (![fileManager fileExistsAtPath:cacheFolder]) {
        [fileManager createDirectoryAtPath:cacheFolder
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
    }
    
    if (!error) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.videoFilePath]) {
            [[NSFileManager defaultManager] createFileAtPath:self.videoFilePath contents:nil attributes:nil];
        }
        NSURL *fileURL = [NSURL fileURLWithPath:self.videoFilePath];
        self.fileReader = [NSFileHandle fileHandleForReadingFromURL:fileURL error:&error];
        if (!error) {
            self.fileWriter = [NSFileHandle fileHandleForWritingToURL:fileURL error:&error];
        }
    }
}

- (void)_unarchiveInfo {
    _contentInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:self.contentInfoPath];
    _ranges = [NSKeyedUnarchiver unarchiveObjectWithFile:self.rangesPath];
}

#pragma mark - Get Method

- (NSString*)videoFilePath {
    if (!_videoFilePath) {
        _videoFilePath = [self.folderPath stringByAppendingPathComponent:VideoCacheFile];
    }
    return _videoFilePath;
}

- (NSString*)contentInfoPath {
    if (!_contentInfoPath) {
        _contentInfoPath = [self.folderPath stringByAppendingPathComponent:ContentInfoCacheFile];
    }
    return _contentInfoPath;
}

- (NSString*)rangesPath {
    if (!_rangesPath) {
        _rangesPath = [self.folderPath stringByAppendingPathComponent:RangesCacheFile];
    }
    return _rangesPath;
}
@end
