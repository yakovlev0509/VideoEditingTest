//
//  VideoComposer.h
//  VideoSlicer
//
//  Created by dev on 10/30/18.
//  Copyright © 2018 companyName. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoComposer : NSObject

- (void)getVideoFromParts:(NSArray<NSURL*>*)videos completion:(void(^)(BOOL success, NSURL* videoURL))completion;

@end

NS_ASSUME_NONNULL_END
