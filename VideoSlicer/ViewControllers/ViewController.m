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

#pragma mark - Notifications

- (void)playerDidPlayedToEnd:(NSNotification *)notification {

    [self stop];
    [self playContinue];
}

@end
