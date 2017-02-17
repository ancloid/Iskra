//
//  VideoEffect.h
//  vchat
//
//  Created by Alexey Fedotov on 08/01/2017.
//  Copyright © 2017 Ancle Apps. All rights reserved.
//


typedef NS_ENUM(NSInteger, EffectType) {
    NoEffect,
    InvertEffect,
    GrayscaleEffect,
    PosterizeEffect,
    HalftoneEffect,
    SepiaEffect,
    SketchEffect,
    ToonEffect,
    CrosshatchEffect,
    FalseColorEffect,
    PixellateEffect,
    TestEffect
};

@interface VideoEffect : NSObject

@property (nonatomic, readonly) EffectType type;

- (id)initWithType:(EffectType)type;
- (CIImage *)applyEffectTo:(CIImage *)image;
- (CGImageRef)getRefWithEffectFrom:(CGImageRef)image;

@end
