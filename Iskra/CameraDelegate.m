//
//  CameraDelegate.m
//  Iskra
//
//  Created by Alexey Fedotov on 31/01/2017.
//  Copyright © 2017 Ancle Apps. All rights reserved.
//

#import <AVFoundation/AVCaptureSession.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <AVFoundation/AVCaptureInput.h>
#import <AVFoundation/AVCaptureOutput.h> // For capturing frames
#import <CoreVideo/CVPixelBuffer.h> // for using pixel format types
#import "CameraDelegate.h"

@interface CameraDelegate()
{
@private
    AVCaptureSession * m_captureSession; // Lets us set up and control the camera
    AVCaptureDevice * m_camera;
    AVCaptureDeviceInput * m_cameraInput;
    AVCaptureVideoDataOutput * m_videoOutput;
    
    
    GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImagePicture *sourcePicture;
    GPUImageUIElement *uiElementInput;
    
    GPUImageFilterPipeline *pipeline;
    
    NSDate *startTime;
}
@end

@implementation CameraDelegate

- (id)init {
    self = [super init];
    if (self) {
        m_captureSession    = NULL;
        m_camera            = NULL;
        m_cameraInput       = NULL;
        m_videoOutput       = NULL;
        
        self.isFront = YES;
        
        videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetiFrame960x540 cameraPosition:AVCaptureDevicePositionFront];
        videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        //videoCamera.horizontallyMirrorFrontFacingCamera = YES;
        //videoCamera.horizontallyMirrorRearFacingCamera = NO;
        //videoCamera.frameRate = 24;
        //videoCamera.runBenchmark = YES;
        [videoCamera setDelegate:self];
        
        
    }
    
    return self;
}

-(void)switchCamera{
    [videoCamera rotateCamera];
    self.isFront = (videoCamera.cameraPosition == AVCaptureDevicePositionFront);
}

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *convertedImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
    
    if (attachments){
        CFRelease(attachments);
    }
    
    [self.delegate imageCaptured:convertedImage];

}

- (BOOL)startCamera
{
    
    [videoCamera startCameraCapture];
    
    return YES;
}



- ( void ) videoCameraStarted: ( NSNotification * ) note
{
    // This callback has done its job, now disconnect it
    [ [ NSNotificationCenter defaultCenter ] removeObserver: self
                                                       name: AVCaptureSessionDidStartRunningNotification
                                                     object: m_captureSession ];
    
}

- ( void ) copyVideoFrame: ( CMSampleBufferRef ) sampleBuffer
{
    //CVPixelBufferRef pixelBuffer = ( CVPixelBufferRef ) CMSampleBufferGetImageBuffer( sampleBuffer );
    
    //CGImageRef img = [self imageFromSampleBuffer:sampleBuffer];

    //[self.delegate imageCaptured:img];
}


- (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer // Create a CGImageRef from sample buffer data
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);        // Lock the image buffer
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);   // Get information of the image
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    /* CVBufferRelease(imageBuffer); */  // do not call this!
    
    return newImage;
}

- ( void ) captureOutput: ( AVCaptureOutput * ) captureOutput
   didOutputSampleBuffer: ( CMSampleBufferRef ) sampleBuffer
          fromConnection: ( AVCaptureConnection * ) connection
{
    if ( captureOutput == m_videoOutput )
    {
        [ self copyVideoFrame: sampleBuffer ];
    }
}

- ( void ) setupVideoOutput
{
    m_videoOutput = [ [ AVCaptureVideoDataOutput alloc ] init ];
    
    dispatch_queue_t captureQueue = dispatch_queue_create( "captureQueue", DISPATCH_QUEUE_SERIAL );
    
    [ m_videoOutput setSampleBufferDelegate: self queue: captureQueue ];
    
    m_videoOutput.alwaysDiscardsLateVideoFrames = NO;
    
    NSNumber * framePixelFormat = [ NSNumber numberWithInt: kCVPixelFormatType_32BGRA ];
    m_videoOutput.videoSettings = [ NSDictionary dictionaryWithObject: framePixelFormat
                                                               forKey: ( id ) kCVPixelBufferPixelFormatTypeKey ];
    
    [ m_captureSession addOutput: m_videoOutput ];
}

- ( BOOL ) attachCameraToCaptureSession
{
    assert( NULL != m_camera );
    assert( NULL != m_captureSession );
    
    m_cameraInput = NULL;
    
    NSError * error = NULL;
    m_cameraInput = [ AVCaptureDeviceInput deviceInputWithDevice: m_camera error: &error ];
    
    if ( NULL != error )
    {
        return false;
    }
    
    if ( [ m_captureSession canAddInput: m_cameraInput ] )
    {
        [ m_captureSession addInput: m_cameraInput ];
    }
    else
    {
        return false;
    }
    
    return true;
}

- ( BOOL ) findCamera: ( BOOL ) useFrontCamera
{
    m_camera = NULL;
    
    NSArray * devices = [ AVCaptureDevice devicesWithMediaType: AVMediaTypeVideo ];
    
    for ( AVCaptureDevice * device in devices )
    {
        if ( useFrontCamera && AVCaptureDevicePositionFront == [ device position ] )
        {
            m_camera = device;
        }
        else if ( !useFrontCamera && AVCaptureDevicePositionBack == [ device position ] )
        {
            m_camera = device;
        }
    }
    
    if ( NULL != m_camera )
    {
        if ( [ m_camera lockForConfiguration: NULL ] )
        {
            [ m_camera setActiveVideoMinFrameDuration: CMTimeMake( 1, 10 ) ];
            
            [ m_camera setActiveVideoMaxFrameDuration: CMTimeMake( 1, 30 ) ];
            
            [ m_camera unlockForConfiguration ];
        }
    }
    
    return ( NULL != m_camera );
}


@end
