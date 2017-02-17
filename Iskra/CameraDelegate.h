//
//  CameraDelegate.h
//  vchat
//
//  Created by Alexey Fedotov on 31/01/2017.
//  Copyright © 2017 Ancle Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVCaptureOutput.h>
#import "GPUImage.h"

@protocol CameraDelegate <NSObject>
- (void) imageCaptured:(CIImage *)image;
@end

@interface CameraDelegate : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, GPUImageVideoCameraDelegate>

- (BOOL) startCamera;
- (void) switchCamera;

@property (nonatomic, weak) id <CameraDelegate> delegate;
@property (nonatomic) BOOL isFront;

@end
