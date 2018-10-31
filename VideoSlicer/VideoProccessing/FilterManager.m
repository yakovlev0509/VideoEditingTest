//
//  FilterManager.m
//  VideoSlicer
//
//  Created by dev on 10/30/18.
//  Copyright © 2018 companyName. All rights reserved.
//

#import "FilterManager.h"

#import <CoreImage/CoreImage.h>
#import "CocoaLut.h"

@interface FilterManager ()

@property (nonatomic, strong) CIFilter* cineBasicFilter;
@property (nonatomic, strong) CIFilter* cineDramaFilter;
@property (nonatomic, strong) CIFilter* cineTealOrange2Filter;

@property (nonatomic, strong) LUT3D* cineBasicLUT3D;
@property (nonatomic, strong) LUT3D* cineDramaLUT3D;
@property (nonatomic, strong) LUT3D* cineTealOrange2LUT3D;

@end

@implementation FilterManager

+ (instancetype)shared{
    static FilterManager* shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [FilterManager new];
    });
    return shared;
}

- (instancetype)init{
    
    self = [super init];
    if (self) {
        self.cineBasicFilter = [self filterWithLutName:@"FGCineBasic"];
        self.cineDramaFilter = [self filterWithLutName:@"FG_CineDrama"];
        self.cineTealOrange2Filter = [self filterWithLutName:@"FG_CineTeal&Orange2"];
    
        self.cineBasicLUT3D = [self lutWithLutName:@"FGCineBasic"];
        self.cineDramaLUT3D = [self lutWithLutName:@"FG_CineDrama"];
        self.cineTealOrange2LUT3D = [self lutWithLutName:@"FG_CineTeal&Orange2"];
    }
    return self;
}

#pragma mark - Public

- (UIImage*)filteredImage:(UIImage*)inputImage filterType:(Filter)filter{
    LUT3D* lut3d = nil;
    switch (filter) {
        case FilterCineBasic:
            lut3d = self.cineBasicLUT3D;
            break;
        case FilterCineDrama:
            lut3d = self.cineDramaLUT3D;
            break;
        case FilterCineTealOrange2:
            lut3d = self.cineTealOrange2LUT3D;
            break;
        default:
            lut3d = self.cineBasicLUT3D;
            break;
    }
    UIImage* inputImageRaw = inputImage;
    CIImage* ciimg = [[CIImage alloc] initWithImage:inputImageRaw];
    UIImage* inputImagePrepared = [[UIImage alloc] initWithCIImage:ciimg];
    
    UIImage* resultImg = [lut3d processUIImage:inputImagePrepared withColorSpace:nil];
    return resultImg;
}

- (CIFilter*)filterWithType:(Filter)filter{
    CIFilter* resultFilter = nil;
    switch (filter) {
        case FilterCineBasic:
            resultFilter = self.cineBasicFilter;
            break;
        case FilterCineDrama:
            resultFilter = self.cineDramaFilter;
            break;
        case FilterCineTealOrange2:
            resultFilter = self.cineTealOrange2Filter;
            break;
        default:
            resultFilter = self.cineBasicFilter;
            break;
    }
    return resultFilter;
}

#pragma mark - Private

- (LUT3D*)lutWithLutName:(NSString*)lutName{
    NSURL *url = [[NSBundle mainBundle] URLForResource:lutName withExtension:@"cube"];
    LUT3D* lut3d = [LUT3D LUTFromURL:url];
    return lut3d;
}

- (CIFilter*)filterWithLutName:(NSString*)lutName{
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:lutName withExtension:@"cube"];
    LUT3D* lut3d = [LUT3D LUTFromURL:url];
    CIFilter* filter = [lut3d coreImageFilterWithCurrentColorSpace];
    
    return filter;
}



@end
