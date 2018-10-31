//
//  FilterManager.h
//  VideoSlicer
//
//  Created by dev on 10/30/18.
//  Copyright © 2018 companyName. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CIFilter;

typedef enum{
    FilterCineBasic,
    FilterCineDrama,
    FilterCineTealOrange2
} Filter;

@interface FilterManager : NSObject

+ (instancetype)shared;

- (UIImage*)filteredImage:(UIImage*)inputImage filterType:(Filter)filter;

- (CIFilter*)filterWithType:(Filter)filter;

@end

NS_ASSUME_NONNULL_END
