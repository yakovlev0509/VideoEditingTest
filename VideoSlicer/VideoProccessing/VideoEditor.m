//
//  VideoEditor.m
//  VideoSlicer
//
//  Created by dev on 10/30/18.
//  Copyright © 2018 companyName. All rights reserved.
//

#import "VideoEditor.h"

#import <AVFoundation/AVFoundation.h>

@interface VideoEditor ()

@property (nonatomic, strong) NSMutableArray<NSURL*>* videoURLs;

@property (nonatomic, strong) AVURLAsset *sourceAsset;
@property (nonatomic, strong) NSURL *sourceURL;
@property (nonatomic, copy) void(^completion)(BOOL success, NSMutableArray* videoURLs);
@property (nonatomic, assign) NSUInteger exportCount;

@end

@implementation VideoEditor

- (instancetype)init{
    
    self = [super init];
    if (self) {
        self.videoURLs = [NSMutableArray new];
        self.exportCount = 5;
        self.sourceURL = [self sourceVideo];
    }
    return self;
}

- (void)splitedVideosCompletion:(void(^)(BOOL success, NSMutableArray* videoURLs))completion{
    
    [self.videoURLs removeAllObjects];
    
    self.completion = completion;

    for (int i = 0; i < self.exportCount; i++){
        [self getVideoNumber:i];
    }
}

- (NSURL*)sourceVideo{
    
    NSString *docsDir = [[NSBundle mainBundle] resourcePath];
    NSString* sourceVideoFilePath = [docsDir stringByAppendingPathComponent:@"VideoFile.mp4"];
    
    NSURL* videoURL = [NSURL fileURLWithPath:sourceVideoFilePath];
    return videoURL;
}

- (AVAssetExportSession*)sessionWthURL:(NSURL*)url{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    self.sourceAsset = asset;
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    return exportSession;
}

- (void)getVideoNumber:(NSUInteger)videoNumber {
    
    AVAssetExportSession* exportSession = [self sessionWthURL:self.sourceURL];
    double partDuration = CMTimeGetSeconds(self.sourceAsset.duration)/self.exportCount;
    NSURL* outputURL = [self outputURLWithNumber:videoNumber];
    
    exportSession.outputURL = outputURL;
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;

    CMTime startTime = CMTimeMakeWithSeconds(videoNumber*partDuration, 1);
    CMTime duration = CMTimeMakeWithSeconds(partDuration, 1);
    CMTimeRange timeRange = CMTimeRangeMake(startTime, duration);
    
    exportSession.timeRange = timeRange;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {

        [self handleExport:exportSession];
     }];
}

- (NSURL*)outputURLWithNumber:(NSUInteger)number{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs;
    
    myPathDocs =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"SplitedVideo_%lu.mov",number]];

    NSFileManager *fileManager = [NSFileManager new];
    NSError *error;
    if ([fileManager fileExistsAtPath:myPathDocs] == YES) {
        [fileManager removeItemAtPath:myPathDocs error:&error];
    }
    
    NSURL* outputURL = [NSURL fileURLWithPath:myPathDocs];
    return outputURL;
}

- (void)handleExport:(AVAssetExportSession*)exportSession{
    if (exportSession.status == AVAssetExportSessionStatusCompleted) {
        NSURL *outputURL = exportSession.outputURL;
      
        [self.videoURLs addObject:outputURL];
        
        if ([self exportFinishedSuccessfully]) {
            if (self.completion) {
                [self sort];
                self.completion(YES, self.videoURLs);
            }
        }
    } else{
        
        if (self.completion) {
            self.completion(NO, nil);
        }
    }
}

- (BOOL)exportFinishedSuccessfully{
    BOOL success = self.videoURLs.count == self.exportCount;
    return success;
}

- (void)sort{
    
    [self.videoURLs sortUsingComparator:^NSComparisonResult(NSURL* _Nonnull url1, NSURL* _Nonnull url2) {
        
        
        return [self compareURL:url1 withURL:url2];

    }];
    
}

- (NSComparisonResult)compareURL:(NSURL*)url1 withURL:(NSURL*)url2{
    
    NSUInteger url1Number = [self numberOfURL:url1];
    NSUInteger url2Number = [self numberOfURL:url2];
    if (url1Number < url2Number) {
        return NSOrderedAscending;
    } if (url1Number > url2Number){
        return NSOrderedDescending;
    } else{
        return NSOrderedSame;
    }
}

- (NSUInteger)numberOfURL:(NSURL*)url{
    
    NSString* lastPathComp = url.lastPathComponent;
    NSRange range1 = [lastPathComp rangeOfString:@"_"];
    NSRange range2 = [lastPathComp rangeOfString:@".mov"];
    lastPathComp = [lastPathComp substringWithRange:NSMakeRange(range1.location+1, range2.location-range1.location-1 )];
    return lastPathComp.integerValue;
}

@end
