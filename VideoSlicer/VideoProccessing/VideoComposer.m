//
//  VideoComposer.m
//  VideoSlicer
//
//  Created by dev on 10/30/18.
//  Copyright © 2018 companyName. All rights reserved.
//

#import "VideoComposer.h"

#import <AVFoundation/AVFoundation.h>

@implementation VideoComposer

- (void)getVideoFromParts:(NSArray*)videos completion:(void(^)(BOOL success, NSURL* videoURL))completion{
    
    CGFloat totalDuration;
    totalDuration = 0;
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    
    CMTime insertTime = kCMTimeZero;
    
    for (NSURL* videoURL in videos) {
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoURL.path]];
        
        CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
        
        [videoTrack insertTimeRange:timeRange
                            ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                             atTime:insertTime
                              error:nil];
        
        [audioTrack insertTimeRange:timeRange
                            ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                             atTime:insertTime
                              error:nil];
        
        insertTime = CMTimeAdd(insertTime,asset.duration);
    }
    
    NSString* documentsDirectory= [self applicationDocumentsDirectory];
    NSString* myDocumentPath = [documentsDirectory stringByAppendingPathComponent:@"mergedVideo.mp4"];
    NSURL* urlVideoMain = [[NSURL alloc] initFileURLWithPath:myDocumentPath];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:myDocumentPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:myDocumentPath error:nil];
    }
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
    exporter.outputURL = urlVideoMain;
    exporter.outputFileType = @"com.apple.quicktime-movie";
    exporter.shouldOptimizeForNetworkUse = YES;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
        BOOL sussess = exporter.status == AVAssetExportSessionStatusCompleted;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(sussess, exporter.outputURL);
            }
        });
    }];
}

- (NSString*)applicationDocumentsDirectory {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end
