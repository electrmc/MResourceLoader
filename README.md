# MResourceLoader

### CocoaPods

`pod 'MResourceLoader'`

### Usage

**Objective C**

```Objc
NSURL *url = [NSURL URLWithString:@"http://www.w3school.com.cn/example/html5/mov_bbb.mp4"];
url = [MResourceScheme mrSchemeURL:url];
self.asset = [[AVURLAsset alloc] initWithURL:url options:nil];
self.loader = [MResourceLoader new];
[self.asset.resourceLoader setDelegate:self.loader queue:dispatch_get_main_queue()];
self.playitem = [AVPlayerItem playerItemWithAsset:self.asset];
self.player = [AVPlayer playerWithPlayerItem:self.playitem];
```
### Contact

miaochaomc@163.com  

miaochaomc@gmail.com

### License

MIT
