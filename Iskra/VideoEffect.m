//
//  VideoEffect.m
//  Iskra
//
//  Created by Alexey Fedotov on 08/01/2017.
//  Copyright © 2017 Ancle Apps. All rights reserved.
//

#import "VideoEffect.h"
#import "GPUImage.h"

@implementation VideoEffect


-(id)initWithType:(EffectType)type{
    if((self = [super init])) {
        _type = type;
    }
    return self;
}

- (GPUImageFilter *)getColorFilterFor:(EffectType)type{
    GPUImageFilter *filter;
    
    switch (type) {
        case InvertEffect:
            filter = [GPUImageColorInvertFilter new];
            break;
        case GrayscaleEffect:
            filter = [GPUImageGrayscaleFilter new];
            break;
        case PosterizeEffect:
            filter = [GPUImagePosterizeFilter new];
            [(GPUImagePosterizeFilter *)filter setColorLevels:round(5)];
            break;
        case HalftoneEffect:
            filter = [GPUImageHalftoneFilter new];
            [(GPUImagePixellateFilter *)filter setFractionalWidthOfAPixel:0.02];
            break;
        case SepiaEffect:
            filter = [GPUImageSepiaFilter new];
            break;
        case SketchEffect:
            filter = [GPUImageSketchFilter new];
            break;
        case ToonEffect:
            filter = [GPUImageToonFilter new];
            break;
        case CrosshatchEffect:
            filter = [GPUImageCrosshatchFilter new];
            [(GPUImageCrosshatchFilter *)filter setCrossHatchSpacing:0.04];
            break;
        case FalseColorEffect:
            filter = [GPUImageFalseColorFilter new];
            break;
        case PixellateEffect:
            filter = [GPUImagePixellateFilter new];
            [(GPUImagePixellateFilter *)filter setFractionalWidthOfAPixel:0.02];
            break;
        case TestEffect:
            filter = [GPUImageSobelEdgeDetectionFilter new];
            break;
        default:
            break;
    }
    
    if(!filter){
        return nil;
    }
    return filter;
}

//used
- (CGImageRef)getRefWithEffectFrom:(CGImageRef)image{
    GPUImageFilter * filter = [self getColorFilterFor:self.type];
    if(!filter){
        return image;
    }
    
    CGImageRef ref = [filter newCGImageByFilteringCGImage:image];
    CGImageRelease(image);
   
    return ref;
}

//not used
- (CIImage *)applyEffectTo:(CIImage *)image{
    
    GPUImageFilter * filter = [self getColorFilterFor:self.type];
    if(!filter){
        return image;
    }
    CGImageRef ref = [filter newCGImageByFilteringCGImage:[image CGImage]];
    CIImage *ciimage = [CIImage imageWithCGImage:ref];
    return ciimage;
}

@end
