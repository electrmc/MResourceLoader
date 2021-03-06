//
//  MResourceFileHandler.h
//  MResourceLoader
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>
#import "MResourceUtility.h"
#import "MResourceContentInfo.h"

@interface MResourceFileLock : NSObject
@property (nonatomic, strong, readonly) NSLock *fileLock;
+ (instancetype)fileIDManager;
@end

@interface MResourceFileHandler : NSObject

@property (nonatomic, strong, readonly) MResourceContentInfo *contentInfo;

@property (nonatomic, strong, readonly) NSArray<NSString*> *ranges;

- (instancetype)initWithResourceID:(NSURL*)url;

- (BOOL)writeData:(NSData*)data range:(MRRange)range error:(NSError**)error;

- (NSData*)readDataForRange:(MRRange)range error:(NSError**)error;

- (BOOL)saveContentInfo:(MResourceContentInfo*)contentInfo;

- (BOOL)saveRanges:(NSArray<NSString*>*)ranges;

@end
