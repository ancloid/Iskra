//
//  MaskEffect.m
//  vchat
//
//  Created by Alexey Fedotov on 05/02/2017.
//  Copyright © 2017 Ancle Apps. All rights reserved.
//

#import "MaskEffect.h"

@implementation MaskEffect

-(id)initWithType:(MaskType)type{
    if((self = [super init])) {
        _type = type;
    }
    return self;
}

-(NSString *)maskForType:(MaskType)type{
    NSString *name;
    switch (type) {
        case NoMask:
            name = @"";
            break;
        case FirstMask:
            name = @"glasses_0";
            break;
        case SecondMask:
            name = @"glasses_1";
            break;
        case ThirdMask:
            name = @"glasses_2";
            break;
    }
    
    return name;
}

- (CIImage *)getCIImageFrom:(CIImage *)image{
    
    if(self.type == NoMask){
        return image;
    }
    
    //my
    CIContext *cicontext = [CIContext contextWithOptions:nil];
    NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, @(YES), CIDetectorTracking, nil];
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:cicontext
                                              options:detectorOptions];
    
    //set orientation
    int exifOrientation = 6; //for portrait mode
    NSDictionary *imageOptions = @{CIDetectorImageOrientation : @(exifOrientation)};
    
    //get array
    NSArray *faceArray = [detector featuresInImage:image options:imageOptions];
    
    //get mask
    CIImage *foreground = [CIImage imageWithContentsOfURL: [[NSBundle mainBundle] URLForResource:[self maskForType:self.type] withExtension:@"png"]];
    
    for (CIFaceFeature *f in faceArray) {
        CIImage *item;
        
        CGFloat centerEX = (f.leftEyePosition.x + f.rightEyePosition.x) / 2.0;
        CGFloat centerEY = (f.leftEyePosition.y + f.rightEyePosition.y) / 2.0;
        
        CGFloat magic = (f.rightEyePosition.y - f.leftEyePosition.y)/135.0;
        
        item = [foreground imageByApplyingTransform:CGAffineTransformMakeScale(magic, magic)];
        CGFloat centerIX = centerEX - item.extent.size.width/2.5;
        CGFloat centerIY = centerEY - item.extent.size.height/2;
        item = [item imageByApplyingTransform:CGAffineTransformMakeTranslation(centerIX, centerIY)];
        
        //combine two pics
        CIFilter *filter = [CIFilter filterWithName:@"CISourceOverCompositing"];
        [filter setValue:image forKey:kCIInputBackgroundImageKey];
        [filter setValue:item forKey:kCIInputImageKey];
        image = [filter outputImage];
    }
    
    return image;
    
    /*
    NSDictionary *imageOptions = nil;
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    int exifOrientation = 6;
     
     
     
    */
}

@end
