//
//  ViewController.m
//  MResourceLoaderDemo
//
//  Created by MiaoChao on 2018/8/28.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MResourceLoader.h"

@interface ViewController ()
@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, strong) AVPlayerItem *playitem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playLayer;
@property (nonatomic, strong) MResourceLoader *loader;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)loadResource:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://videoplayer.babytreeimg.com/2018/0718/lrV0B9pCh_b4yEreB-PvX89-bYZw.mp4"];
    url = [MResourceScheme mrSchemeURL:url];
    self.asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    self.loader = [MResourceLoader new];
    [self.asset.resourceLoader setDelegate:self.loader queue:dispatch_get_main_queue()];
    self.playitem = [AVPlayerItem playerItemWithAsset:self.asset];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playitem];
    self.playLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playLayer.frame = CGRectMake(0, 200, self.view.bounds.size.width, 400);
    [self.view.layer addSublayer:self.playLayer];
    [self.player play];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        if (self.playitem.status == AVPlayerItemStatusFailed) {
            NSLog(@"连接失败");
        }else if (self.playitem.status == AVPlayerItemStatusUnknown){
            NSLog(@"未知的错误");
        }else if(self.playitem.status == AVPlayerItemStatusReadyToPlay){
            NSLog(@"准备播放");
            CGFloat time = CMTimeGetSeconds(self.playitem.duration);
            NSLog(@"总时长： %f",time);
        } else {
            NSLog(@"other status");
        }
        
    } else if([keyPath isEqualToString:@"loadedTimeRanges"]) {
        // 计算缓冲进度
        NSTimeInterval timeInterval = [self availableDuration];
        CMTime duration             = self.playitem.duration;
        CGFloat totalDuration       = CMTimeGetSeconds(duration);
        NSLog(@"duration : %f, %f",duration.value,duration.timescale);
        
    } else if([keyPath isEqualToString:@"playbackBufferEmpty"]){
        
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        
    }
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

@end
