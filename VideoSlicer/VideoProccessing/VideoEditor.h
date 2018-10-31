//
//  VideoEditor.h
//  VideoSlicer
//
//  Created by dev on 10/30/18.
//  Copyright © 2018 companyName. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoEditor : NSObject

- (void)splitedVideosCompletion:(void(^)(BOOL success, NSMutableArray* videoURLs))completion;

@end

NS_ASSUME_NONNULL_END
