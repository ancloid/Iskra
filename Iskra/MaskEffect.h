//
//  MaskEffect.h
//  Iskra
//
//  Created by Alexey Fedotov on 05/02/2017.
//  Copyright © 2017 Ancle Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MaskType) {
    NoMask,
    FirstMask,
    SecondMask,
    ThirdMask,
    FourthMask,
    FifthMask
};


@interface MaskEffect : NSObject

@property (nonatomic, readonly) MaskType type;

- (id)initWithType:(MaskType)type;
- (CIImage *)getCIImageFrom:(CIImage *)image;

@end
