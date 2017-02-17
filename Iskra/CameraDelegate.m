//
//  CameraDelegate.m
//  vchat
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
    
    //raw old
    /*
    CGImageRef img = [self imageFromSampleBuffer:sampleBuffer];
    [self.delegate imageCaptured:img];
    */
    
    //CFAllocatorRef allocator = CFAllocatorGetDefault();
    //CMSampleBufferRef sbufCopyOut;
    //CMSampleBufferCreateCopy(allocator,sampleBuffer,&sbufCopyOut);
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *convertedImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
    
    if (attachments){
        CFRelease(attachments);
    }
    
    //NSLog(@"----> %@", [NSString stringWithFormat:@"Time: %f s", - [startTime timeIntervalSinceNow]]);
    
    [self.delegate imageCaptured:convertedImage];

}

- (BOOL)startCamera
{
    //filter = [[GPUImageSepiaFilter alloc] init];
    //filter = [[GPUImageColorInvertFilter alloc] init];
    //[videoCamera addTarget:filter];
    //GPUImageView *filterView = (GPUImageView *)view;
    //[filter addTarget:filterView];
    
    ///startTime = [NSDate date];
    
    [videoCamera startCameraCapture];
    
    return YES;
    
    // 1. Find the back camera
    if ( ![ self findCamera: true ] )
    {
        return false;
    }
    
    //2. Make sure we have a capture session
    if ( NULL == m_captureSession )
    {
        m_captureSession = [ [ AVCaptureSession alloc ] init ];
    }
    
    // 3. Choose a preset for the session.
    NSString * cameraResolutionPreset = AVCaptureSessionPresetiFrame960x540;
    
    // 4. Check if the preset is supported on the device by asking the capture session:
    if ( ![ m_captureSession canSetSessionPreset: cameraResolutionPreset ] )
    {
        // Optional TODO: Send an error event to ActionScript
        return false;
    }
    
    // 4.1. The preset is OK, now set up the capture session to use it
    [ m_captureSession setSessionPreset: cameraResolutionPreset ];
    
    // 5. Plug camera and capture sesiossion together
    [ self attachCameraToCaptureSession ];
    
    // 6. Add the video output
    [ self setupVideoOutput ];
    
    // 7. Set up a callback, so we are notified when the camera actually starts
    [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                selector: @selector( videoCameraStarted: )
                                                    name: AVCaptureSessionDidStartRunningNotification
                                                  object: m_captureSession ];
    
    // 8. 3, 2, 1, 0... Start!
    [ m_captureSession startRunning ];
    
    // Note: Returning true from this function only means that setting up went OK.
    // It doesn't mean that the camera has started yet.
    // We get notified about the camera having started in the videoCameraStarted() callback.
    return true;
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
    
    
    //CGImageRelease( newImage );
    
    return newImage;
}

/*
#define clamp(a) (a>255?255:(a<0?0:a))


- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    uint8_t *yBuffer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t yPitch = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    uint8_t *cbCrBuffer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
    size_t cbCrPitch = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 1);
    
    int bytesPerPixel = 4;
    uint8_t *rgbBuffer = malloc(width * height * bytesPerPixel);
    
    for(int y = 0; y < height; y++) {
        uint8_t *rgbBufferLine = &rgbBuffer[y * width * bytesPerPixel];
        uint8_t *yBufferLine = &yBuffer[y * yPitch];
        uint8_t *cbCrBufferLine = &cbCrBuffer[(y >> 1) * cbCrPitch];
        
        for(int x = 0; x < width; x++) {
            int16_t y = yBufferLine[x];
            int16_t cb = cbCrBufferLine[x & ~1] - 128;
            int16_t cr = cbCrBufferLine[x | 1] - 128;
            
            uint8_t *rgbOutput = &rgbBufferLine[x*bytesPerPixel];
            
            int16_t r = (int16_t)roundf( y + cr *  1.4 );
            int16_t g = (int16_t)roundf( y + cb * -0.343 + cr * -0.711 );
            int16_t b = (int16_t)roundf( y + cb *  1.765);
            
            rgbOutput[0] = 0xff;
            rgbOutput[1] = clamp(b);
            rgbOutput[2] = clamp(g);
            rgbOutput[3] = clamp(r);
        }
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbBuffer, width, height, 8, width * bytesPerPixel, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(quartzImage);
    free(rgbBuffer);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}*/

- ( void ) captureOutput: ( AVCaptureOutput * ) captureOutput
   didOutputSampleBuffer: ( CMSampleBufferRef ) sampleBuffer
          fromConnection: ( AVCaptureConnection * ) connection
{
    // 1. Check if this is the output we are expecting:
    if ( captureOutput == m_videoOutput )
    {
        // 2. If it's a video frame, copy it from the sample buffer:
        [ self copyVideoFrame: sampleBuffer ];
    }
}

- ( void ) setupVideoOutput
{
    // 1. Create the video data output
    m_videoOutput = [ [ AVCaptureVideoDataOutput alloc ] init ];
    
    // 2. Create a queue for capturing video frames
    dispatch_queue_t captureQueue = dispatch_queue_create( "captureQueue", DISPATCH_QUEUE_SERIAL );
    
    // 3. Use the AVCaptureVideoDataOutputSampleBufferDelegate capabilities of CameraDelegate:
    [ m_videoOutput setSampleBufferDelegate: self queue: captureQueue ];
    
    // 4. Set up the video output
    // 4.1. Do we care about missing frames?
    m_videoOutput.alwaysDiscardsLateVideoFrames = NO;
    
    // 4.2. We want the frames in some RGB format, which is what ActionScript can deal with
    NSNumber * framePixelFormat = [ NSNumber numberWithInt: kCVPixelFormatType_32BGRA ];
    m_videoOutput.videoSettings = [ NSDictionary dictionaryWithObject: framePixelFormat
                                                               forKey: ( id ) kCVPixelBufferPixelFormatTypeKey ];
    
    // 5. Add the video data output to the capture session
    [ m_captureSession addOutput: m_videoOutput ];
}

- ( BOOL ) attachCameraToCaptureSession
{
    // 0. Assume we've found the camera and set up the session first:
    assert( NULL != m_camera );
    assert( NULL != m_captureSession );
    
    // 1. Initialize the camera input
    m_cameraInput = NULL;
    
    // 2. Request a camera input from the camera
    NSError * error = NULL;
    m_cameraInput = [ AVCaptureDeviceInput deviceInputWithDevice: m_camera error: &error ];
    
    // 2.1. Check if we've got any errors
    if ( NULL != error )
    {
        // TODO: send an error event to ActionScript
        return false;
    }
    
    // 3. We've got the input from the camera, now attach it to the capture session:
    if ( [ m_captureSession canAddInput: m_cameraInput ] )
    {
        [ m_captureSession addInput: m_cameraInput ];
    }
    else
    {
        // TODO: send an error event to ActionScript
        return false;
    }
    
    // 4. Done, the attaching was successful, return true to signal that
    return true;
}

- ( BOOL ) findCamera: ( BOOL ) useFrontCamera
{
    // 0. Make sure we initialize our camera pointer:
    m_camera = NULL;
    
    // 1. Get a list of available devices:
    // specifying AVMediaTypeVideo will ensure we only get a list of cameras, no microphones
    NSArray * devices = [ AVCaptureDevice devicesWithMediaType: AVMediaTypeVideo ];
    
    // 2. Iterate through the device array and if a device is a camera, check if it's the one we want:
    for ( AVCaptureDevice * device in devices )
    {
        if ( useFrontCamera && AVCaptureDevicePositionFront == [ device position ] )
        {
            // We asked for the front camera and got the front camera, now keep a pointer to it:
            m_camera = device;
        }
        else if ( !useFrontCamera && AVCaptureDevicePositionBack == [ device position ] )
        {
            // We asked for the back camera and here it is:
            m_camera = device;
        }
    }
    
    // 3. Set a frame rate for the camera:
    if ( NULL != m_camera )
    {
        // We firt need to lock the camera, so noone else can mess with its configuration:
        if ( [ m_camera lockForConfiguration: NULL ] )
        {
            // Set a minimum frame rate of 10 frames per second
            [ m_camera setActiveVideoMinFrameDuration: CMTimeMake( 1, 10 ) ];
            
            // and a maximum of 30 frames per second
            [ m_camera setActiveVideoMaxFrameDuration: CMTimeMake( 1, 30 ) ];
            
            [ m_camera unlockForConfiguration ];
        }
    }
    
    // 4. If we've found the camera we want, return true
    return ( NULL != m_camera );
}


@end
