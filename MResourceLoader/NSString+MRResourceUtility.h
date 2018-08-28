//
//  NSString+MRResourceUtility.h
//  MResourceDemo
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MResourceUtility.h"

@interface NSString (MRResourceUtility)

- (NSString*)mr_md5;

+ (NSString*)stringFromRange:(MRRange) range;
- (MRRange)MRRange;

@end
