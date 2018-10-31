//
//  ViewController.m
//  VideoSlicer
//
//  Created by dev on 10/30/18.
//  Copyright © 2018 companyName. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import "VideoComposer.h"
#import "VideoEditor.h"
#import "FilterManager.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView* playerView;

@property (nonatomic, strong) VideoEditor* editor;
@property (nonatomic, strong) VideoComposer* composer;

@property (nonatomic, strong) NSURL* videoURL;
@property (nonatomic, weak) IBOutlet UIButton* playPauseButton;
@property (nonatomic, strong) AVPlayer* player;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* activityView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidPlayedToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player];

    self.editor = [VideoEditor new];
    
    self.composer = [VideoComposer new];
    
    [self.activityView startAnimating];
    [self.editor splitedVideosCompletion:^(BOOL successSplit, NSMutableArray * _Nonnull videoURLs) {
        
        [self.composer getVideoFromParts:videoURLs completion:^(BOOL successComposition, NSURL* videoURL){
            
            self.videoURL = videoURL;
            [self setupPlayer];
            [self.activityView stopAnimating];
        }];
    }];
    
}

#pragma mark - Submethods

- (void)setupPlayer{
    
    if (!self.videoURL) {
        return;
    }
    NSString *filepath = self.videoURL.path;
    NSURL *fileURL = [NSURL fileURLWithPath:filepath];
    self.player = [AVPlayer playerWithURL:fileURL];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    videoLayer.frame = self.playerView.bounds;

    videoLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.playerView.layer addSublayer:videoLayer];
    
}

- (void)playContinue{
    [self.player play];
}

- (void)pause{
    [self.player pause];
}

- (void)stop{
    [self.player pause];
    [self.player seekToTime:kCMTimeZero];
    
}

- (void)layoutPlaying{
    [self.playPauseButton setTitle:@"pause" forState:(UIControlStateNormal)];
}

- (void)layoutPause{
    [self.playPauseButton setTitle:@"play" forState:(UIControlStateNormal)];
}

- (void)applyFilter:(NSArray<CIFilter*>*)filters{
    
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:self.videoURL.path]];
    
    __weak typeof(self) weakSelf = self;
    __block BOOL isFilterEnabled = YES;
    AVVideoComposition* videoComposition = [AVVideoComposition videoCompositionWithAsset:asset applyingCIFiltersWithHandler:^(AVAsynchronousCIImageFilteringRequest *request){
        if (isFilterEnabled) {
            [request finishWithImage:request.sourceImage context:nil];
            return;
        }
        CIImage* filteredFrame = [weakSelf processRequest:request withFilters:filters];
        CIImage *output = [filteredFrame imageByCroppingToRect:request.sourceImage.extent];
        [request finishWithImage:output context:nil];
    }];
    self.player.currentItem.videoComposition = videoComposition;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        isFilterEnabled = NO;
    });
}

- (CIImage*)processRequest:(AVAsynchronousCIImageFilteringRequest *)request withFilters:(NSArray*)filters{
    
    CIImage *result = [request.sourceImage imageByClampingToExtent];
    for (CIFilter* filter in filters) {
        
        [filter setValue:result forKey:kCIInputImageKey];
        CIImage *output = filter.outputImage;
        result = output;
    }
    return result;
}

#pragma mark - Actions

- (IBAction)onPlayPause:(id)sender{
    
    if (self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
        [self pause];
        [self layoutPause];
    } else if (self.player.timeControlStatus == AVPlayerTimeControlStatusPaused){
        [self playContinue];
        [self layoutPlaying];
    }
}

- (IBAction)onStop:(id)sender{
    
    [self stop];
    [self layoutPause];
}

- (IBAction)onAllFiltersButton:(id)sender{
    
    CIFilter *filter1 = [[FilterManager shared] filterWithType:FilterCineBasic];
    CIFilter *filter2 = [[FilterManager shared] filterWithType:FilterCineDrama];
    CIFilter *filter3 = [[FilterManager shared] filterWithType:FilterCineTealOrange2];
    NSArray* filters = @[filter1,filter2,filter3];
    [self applyFilter:filters];
}

- (IBAction)onCineBasicFilterButton:(id)sender{
    
    CIFilter *filter = [[FilterManager shared] filterWithType:FilterCineBasic];
    [self applyFilter:@[filter]];
}


- (IBAction)onDramaFilterButton:(id)sender{
    
    CIFilter *filter = [[FilterManager shared] filterWithType:FilterCineDrama];
    [self applyFilter:@[filter]];
}

- (IBAction)onTealOrageButton:(id)sender{
    CIFilter *filter = [[FilterManager shared] filterWithType:FilterCineTealOrange2];
    [self applyFilter:@[filter]];
}

#pragma mark - Notifications

- (void)playerDidPlayedToEnd:(NSNotification *)notification {

    [self stop];
    [self playContinue];
}


@end
