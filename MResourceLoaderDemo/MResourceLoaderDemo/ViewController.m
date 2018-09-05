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
#import "MResourceCacheManager.h"
#import "MResourceDataFetcher.h"

@interface ViewController ()
@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, strong) AVPlayerItem *playitem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playLayer;
@property (nonatomic, strong) MResourceLoader *loader;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (nonatomic, assign) MRRange range;
@property (nonatomic, assign) NSUInteger receiveDataLength;
@property (nonatomic, strong) NSMutableSet *set;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableDictionary *dic;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.receiveDataLength = 0;
    self.set = [NSMutableSet set];
}

- (void)_configVideoPlayer {
//    NSURL *url = [NSURL URLWithString:@"https://media.w3.org/2010/05/sintel/trailer.mp4"];
//    NSURL *url = [NSURL URLWithString:@"http://yun.it7090.com/video/XHLaunchAd/video03.mp4"];
    NSURL *url = [NSURL URLWithString:@"http://www.w3school.com.cn/example/html5/mov_bbb.mp4"];

    url = [MResourceScheme mrSchemeURL:url];
    self.asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    self.loader = [MResourceLoader new];
    [self.asset.resourceLoader setDelegate:self.loader queue:dispatch_get_main_queue()];
    self.playitem = [AVPlayerItem playerItemWithAsset:self.asset];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playitem];
    self.playLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playLayer.frame = CGRectMake(0, 100, self.view.bounds.size.width, 400);
    self.playLayer.backgroundColor = [UIColor blackColor].CGColor;
    [self.view.layer addSublayer:self.playLayer];
}

- (void)_addTimeObserver {
    [self.playitem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playitem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playitem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.playitem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    __weak __typeof__(self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 100) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);
        NSLog(@"current play time : %f",current);
        if (current >= 0) {
            __typeof__(weakSelf) self = weakSelf;
            self.slider.value = current;
        }
    }];
}

- (IBAction)play:(id)sender {
    [self _configVideoPlayer];
    [self _addTimeObserver];
    [self.player play];
}

- (IBAction)stop:(id)sender {
    [self.player pause];
}

- (IBAction)clearCache:(id)sender {
    [[MResourceCacheManager defaultManager] clearAllCache];
}

/**
 first: pause
 then:  seek to time
 end :  play
 */
- (IBAction)slider:(UISlider*)sender {
    [self.player seekToTime:CMTimeMake(sender.value, 1)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        if (self.playitem.status == AVPlayerItemStatusFailed) {
            NSLog(@"AVPlayerItemStatusFailed");
        }else if (self.playitem.status == AVPlayerItemStatusUnknown){
            NSLog(@"AVPlayerItemStatusUnknown");
        }else if(self.playitem.status == AVPlayerItemStatusReadyToPlay){
            NSLog(@"AVPlayerItemStatusReadyToPlay");
            CGFloat time = CMTimeGetSeconds(self.playitem.duration);
            self.slider.maximumValue = time;
            NSLog(@"resource duration : %f",time);
        } else {
            NSLog(@"other status");
        }
        
    } else if([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
    } else if([keyPath isEqualToString:@"playbackBufferEmpty"]){
        
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        
    }
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;
    return result;
}

@end
