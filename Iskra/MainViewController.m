//
//  MainViewController.m
//  Iskra
//
//  Created by Alexey Fedotov on 19/08/16.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import <videoprp/AgoraVideoSourceObjc.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>

#import "SVProgressHUD.h"
#import <RESideMenu/RESideMenu.h>
#import <SpriteKit/SpriteKit.h>
#import "RegisterViewController.h"
#import "IntroViewController.h"
#import <PopupDialog/PopupDialog-Swift.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MZTimerLabel.h"
#import "MainViewController.h"
#import "Utils.h"
#import "LoginManager.h"
#import "ApiManager.h"
#import "User.h"
#import "Chat.h"
#import "Utils.h"
#import "DataManager.h"
#import "JDStatusBarNotification.h"
#import "INTUAnimationEngine.h"
#import "LoginPopup.h"
#import "EndPopup.h"
#import "LocationManager.h"
#import "CameraDelegate.h"
#import "VideoEffect.h"
#import "MaskEffect.h"
#import "StoreManager.h"

typedef NS_ENUM(NSInteger, EffectsType) {
    Filters,
    Masks
};

typedef NS_ENUM(NSInteger, TimerType) {
    TimerSearch,
    TimerDecision
};

@interface MainViewController ()<CameraDelegate, AgoraRtcEngineDelegate, MZTimerLabelDelegate, UICollectionViewDataSource, UICollectionViewDelegate>{
    
    MZTimerLabel *mainTimer;
    MZTimerLabel *chatTimer;
    LoginManager *loginManager;
    
    SKScene* scene;
    SKEmitterNode *effectEmitter;
    
    AgoraVideoSource *agoraSource;
}

@property (nonatomic) CameraDelegate *cameraDelegate;

@property (strong, nonatomic) VideoEffect *videoEffect;
@property (strong, nonatomic) MaskEffect *maskEffect;

@property (strong, nonatomic) UIImageView *cameraImageView;

//Agora
@property (strong, nonatomic) AgoraRtcEngineKit *agoraKit;
@property (strong, nonatomic) AgoraRtcVideoCanvas *bigCanvas;
@property (strong, nonatomic) AgoraRtcVideoCanvas *smallCanvas;

@property (nonatomic) Chat *chat;
@property (nonatomic) User *user;
@property NSInteger chatStatus;
@property NSInteger nowDeviceID;
@property (nonatomic) NSArray *filtersArray;
@property (nonatomic) NSArray *masksArray;
@property (nonatomic) NSInteger nowEffect;
@property (nonatomic) UIViewController *introViewController;

@property (nonatomic) LoginPopup *loginPopup;
@property (nonatomic) EndPopup *endPopup;

@property (nonatomic) BOOL isMeShowed;

@end

@implementation MainViewController


//temp sockets status
-(void)setStatus:(NSString *)status{
    //[JDStatusBarNotification showWithStatus:status dismissAfter:3];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"chatStatus"];
    [API removeObserver:self forKeyPath:@"apiStatus"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    self.smallView.hidden = YES;
    self.timerView.hidden = YES;
    self.chatUpperBar.hidden = YES;
    self.mainUpperBar.hidden = NO;
    self.shotView.hidden = YES;
    self.connectingView.hidden = YES;
    self.effectsButton.enabled = NO;
    self.cameraButton.enabled = NO;
    self.mainView.hidden = YES;
    
    self.isMeShowed = NO;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.filtersArray = @[@(NoEffect),
                          @(InvertEffect),
                          @(GrayscaleEffect),
                          @(PosterizeEffect),
                          @(HalftoneEffect),
                          @(SepiaEffect),
                          @(SketchEffect),
                          @(ToonEffect),
                          @(CrosshatchEffect),
                          @(FalseColorEffect),
                          @(PixellateEffect),
                          @(TestEffect)];
    
    self.masksArray = @[@(NoMask),
                        @(FirstMask),
                        @(SecondMask),
                        @(ThirdMask),
                        @(FourthMask),
                        @(FifthMask)];
    
    self.maskEffect = [[MaskEffect alloc] initWithType:NoMask];
    self.videoEffect = [[VideoEffect alloc] initWithType:NoEffect];
    
    self.nowEffect = Filters;
    self.nowDeviceID = 1;
   
    [self addObserver:self forKeyPath:@"chatStatus" options:NSKeyValueObservingOptionNew context:nil];
    [API addObserver:self forKeyPath:@"apiStatus" options:NSKeyValueObservingOptionNew context:nil];
    
    self.chatStatus = ChatIniting;
    [self setStatus:@"Initialisation"];
    
    //timer init
    mainTimer = [[MZTimerLabel alloc] initWithLabel:self.timerLabel andTimerType:MZTimerLabelTypeTimer];
    mainTimer.delegate = self;
    mainTimer.timeFormat = @"mm:ss";
    
    //timer init
    chatTimer = [[MZTimerLabel alloc] initWithLabel:self.chatTimerLabel andTimerType:MZTimerLabelTypeTimer];
    chatTimer.delegate = self;
    chatTimer.timeFormat = @"mm:ss";
    
    //popup customization
    [PopupDialogDefaultView appearance].backgroundColor = [UIColor whiteColor];
    [PopupDialogDefaultView appearance].titleFont = [UIFont systemFontOfSize:18];
    [PopupDialogDefaultView appearance].titleColor = [UIColor blackColor];
    [PopupDialogDefaultView appearance].titleTextAlignment = NSTextAlignmentCenter;
    [PopupDialogDefaultView appearance].messageFont = [UIFont systemFontOfSize:14];
    [PopupDialogDefaultView appearance].messageColor = [UIColor darkGrayColor];
    [PopupDialogDefaultView appearance].messageTextAlignment = NSTextAlignmentCenter;
    [PopupDialogContainerView appearance].cornerRadius = 4;
    
    //setup ui things
    
    //update constraits
    [self.view layoutIfNeeded];
    
    self.connectingLabel.text = NSLocalizedString(@"connectingLabel", nil);
    self.onlineLabel.text = @"";
    
    [self.chatUsernameLabel setFont:[UIFont fontWithName:@"Gotham Pro" size:self.chatUsernameLabel.font.pointSize]];
    
    self.loginPopup = [[LoginPopup alloc] initWithRoot:self.navigationController.view];
    self.endPopup = [[EndPopup alloc] initWithRoot:self.navigationController.view];
    
    [self.effectsButton setCornerRadius:self.effectsButton.frame.size.height/2];
    [self.cameraButton setCornerRadius:self.effectsButton.frame.size.height/2];
    [self.startButton setCornerRadius:self.effectsButton.frame.size.height/2];
    
    //init managers
    [LOGIN initWithRoot:self];
    [LOGIN checkFor:Vkontakte];
    [LOGIN checkFor:Facebook];
    
    self.cameraDelegate = [[CameraDelegate alloc] init];
    self.cameraDelegate.delegate = self;
    
    //particles
    //not transparent!
    self.skView.hidden = YES;
    self.skView.userInteractionEnabled = NO;
    self.skView.allowsTransparency = YES;
    
    //SOCKETS
    
#pragma FIRST USERINFO
    [API.socket on:@"config" callback:^(NSArray* data, SocketAckEmitter* ack) {
        DDLogDebug(@"socket config got %@", data);
        [self setConfigWithData:data];
    }];
    
    [API.socket on:@"register_ok" callback:^(NSArray* data, SocketAckEmitter* ack) {
        //TODO: check for doubles
        [self userRegistered];
    }];
    
    [API.socket on:@"chat" callback:^(NSArray* data, SocketAckEmitter* ack) {
        
        if(!data[0]){
            DDLogError(@"ERROR Chat object not found");
            [self stopSearching];
        }
        self.chat = [Chat new];
        [self.chat createWithData:data[0]];
        
        if(self.chat.cid){
            DDLogDebug(@"self.chat.distance %@", self.chat.distance);
            self.chatDistanceLabel.text = self.chat.distance;
            self.chatUsernameLabel.text = [NSString stringWithFormat:@"%@, %@", self.chat.name, self.chat.age];
            [self startChatWithChatId:self.chat.cid];
        }else{
            DDLogError(@"ERROR Chat id not found");
            [self stopSearching];
        }
    }];
    
    [API.socket on:@"searchstop_ok" callback:^(NSArray* data, SocketAckEmitter* ack) {
        DDLogDebug(@"socket searchStop_ok %@", data);
        [self stopSearching];
    }];
    
    [API.socket on:@"stat" callback:^(NSArray* data, SocketAckEmitter* ack) {
        DDLogDebug(@"socket stat %@", data);
        
        NSString *activeCount = [data[0] objectForKey:@"activeCount"];
        int activeCountNum = [activeCount intValue];
        activeCountNum += 3;
        self.onlineLabel.text = [NSString stringWithFormat:NSLocalizedString(@"onlineLabel", nil), activeCountNum];
    }];
    
    [API.socket on:@"contacts" callback:^(NSArray* data, SocketAckEmitter* ack) {
        DDLogDebug(@"contacts %@", data);
        
        [DataManager saveContacts:data];
    }];
    
#pragma mark - Decision from Opponent
    
    [API.socket on:@"approved" callback:^(NSArray* data, SocketAckEmitter* ack) {
        DDLogDebug(@"approved %@", data);
        
        
        [self hideBigCamera];
        
        [self showSuccessPopup];
        [API callMethod:@"getContacts" withData:nil];
    }];
    
    [API.socket on:@"rejected" callback:^(NSArray* data, SocketAckEmitter* ack) {
        DDLogDebug(@"rejected %@", data);
        
        [self hideBigCamera];
        [self showFailPopup];
    }];
    
    [API.socket onAny:^(SocketAnyEvent *event) {
        NSLog(@"ANY EVENT----> %@ %i", event.event, (int)event.items.count);
    }];
    
#pragma mark - Notifications
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground)
     name:UIApplicationDidBecomeActiveNotification object:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LoginSuccessNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *network = note.userInfo[@"network"];
        NSDictionary *data = note.userInfo[@"data"];
        
        [self.user createFor:network withData:data];
        [self checkAllFields];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LoginFailNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self showError:@"Вы обязаны авторизоваться!"];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:YesEndNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self showUI];
        [self sendChatSuccess];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NoEndNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self showUI];
        [self showDecisionPopup];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UserCompleteNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.user = note.userInfo[@"user"];
        [self saveUser];
    }];

    self.cameraImageView = self.bigCameraImageView;
    
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:@"04d32aab9f9542f19e768054ea117f6e" delegate:self];
    [self.agoraKit enableVideo];
    
    [self initUser];
}

-(void)initUser{
    self.user = [DataManager loadUser];
    
    if(self.user){
        self.user.inited = true;
    }else{
        self.user = [User new];
        self.user.inited = false;
    }
    
    //random for a first time, uid for already logged user
    if(!self.user.inited){
        self.user.uid = [Utils randomStringWithLength:20];
    }
    
    if(![DATA readDataWithName:@"intro"]){
        [self showIntro];
        if(![DATA writeData:@YES withName:@"intro"]){
            DDLogError(@"Error save data");
        }
    }
    
    [API.socket connect];
}

- (void)applicationWillEnterForeground {
    NSLog(@"main applicationWillEnterForeground %li", (long)API.apiStatus);
    
    if(API.apiStatus == ApiDisconnected){
        [self setStatus:@"Reconnect"];
        [API.socket reconnect];
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
   
}

-(void)setConfigWithData:(NSArray *)data{
    
    //called after each disconnect!
    
    [API callMethod:@"getStat" withData:nil];
    
    if (!self.isMeShowed) {
        [self checkCameraPermission];
    }else{
        //already connected after reconnct
        [self checkLogin];
    }
}


-(void)checkLogin{
    if (self.user.inited) {
        [self registerUser];
    }else {
        self.chatStatus = ChatLoginNeeded;
    }
}

-(void)checkAllFields{
    
    if(!self.user.male || !self.user.bday){
        [self performSegueWithIdentifier:@"ShowRegistration" sender:self];
        return;
    }
    
    [self saveUser];
}

-(void)saveUser{
    [DataManager saveUser:self.user];
    [self registerUser];
}

//TODO: call this after all disconnect
-(void)registerUser{
    self.chatStatus = ChatIniting;
    
    DDLogDebug(@"----> %@ %@ %@ %@ %@ %@ %@", self.user.uid, self.user.name, self.user.male, self.user.bday, self.user.link, LOCATION.lon, LOCATION.lat);
    
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    DDLogDebug(@"UUID ----> %@", uuid);
    
    NSString *apnsToken = @"";
    if([DATA readDataWithName:@"apnsToken"]){
        apnsToken = [DATA readDataWithName:@"apnsToken"];
        DDLogDebug(@"apnsToken ----> %@", apnsToken);
    }
    
    NSDictionary *userInfo = @{@"id":self.user.uid,@"name":self.user.name,@"male":self.user.male,@"year":self.user.bday,@"url":self.user.link,@"location":@{@"lon":LOCATION.lon,@"lat":LOCATION.lat},@"uuid":uuid,@"token":apnsToken};
    
    [API callMethod:@"register" withData:userInfo];
}


-(void)userRegistered{
    [API callMethod:@"getStat" withData:nil];
    [API callMethod:@"getContacts" withData:nil];
    
    self.chatStatus = ChatStopped;
}

-(void)checkCameraPermission{
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(videoStatus == AVAuthorizationStatusAuthorized) { // authorized
        [self showMe];
    }
    else if(videoStatus == AVAuthorizationStatusDenied){ // denied
        [self showSettingsError:@"Нам нужно включить вашу камеру.\nПожалуйста разрешите доступ в Настройках."];
    }
    else if(videoStatus == AVAuthorizationStatusRestricted){ // restricted
        [self showError:@"Критическая ошибка.\nДоступ к вашей камере заблокирован."];
    }
    else if(videoStatus == AVAuthorizationStatusNotDetermined){ // not determined
        self.chatStatus = ChatReady;
    }
}

-(void)askCameraPermission{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if(granted){
                [self showMe];
            }else{
                [self checkCameraPermission];
            }
        });
    }];
}

#define clamp(a) (a>255?255:(a<0?0:a))

//not used
- (UIImage *)imageFromSampleBuffer:(CVPixelBufferRef)imageBuffer {
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
}

//post (it works but needs reverse decode)
-(void)onFrameAvailable:(unsigned char *)y ubuf:(unsigned char *)u vbuf:(unsigned char *)v ystride:(int)ystride ustride:(int)ustride vstride:(int)vstride width:(int)width height:(int)height{
    
    //back
    //memset(u, 0, ustride*height/2);
    
    UIImage *img = nil;
    
    NSLog(@"onFrameAvailable ----> %i %i", width, height);
    NSLog(@"onFrameAvailable ----> %i %i %i", ystride, ustride, vstride);
    
    NSDictionary *pixelAttributes = @{(id)kCVPixelBufferIOSurfacePropertiesKey : @{}}; //must
    CVPixelBufferRef pixelBuffer = NULL;
    
    
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                          width,
                                          height,
                                          kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                                          (__bridge CFDictionaryRef)(pixelAttributes),
                                          &pixelBuffer);
    
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    //MAKE Y
    uint8_t *yDestPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    memcpy(yDestPlane, y, width * height); //width * height
    
    
    //MAKE UV
    uint8_t *uvDestPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    
    NSLog(@"strlen %lu", sizeof(uvDestPlane));
    
    uint8_t *uv = (unsigned char *)malloc(width * height); //sizeof(uvDestPlane)
    
    // For the uv data, we need to interleave them as uvuvuvuv....
    
    int s = (int)strlen((char*)u);
    
    int iuvRow = height/2;//s*2/width; == 1
    
    NSLog(@"strlen %d", s);
    NSLog(@"iuvRow %d", iuvRow);
    
    int iHalfWidth = width/2;
    int uvDataIndex;
    int uIndex;
    int vIndex;
    
    for (int i = 0; i < iuvRow; i++) {
        for (int j = 0; j < iHalfWidth; j++) {
            // UV data for original frame.  Just interleave them.
            uvDataIndex = i*iHalfWidth+j;
            uIndex = (i*width) + (j*2);
            vIndex = uIndex + 1;
            
            uv[uIndex] = u[uvDataIndex];
            uv[vIndex] = v[uvDataIndex];
        }
    }
    NSLog(@"1 uvDestPlane %@", [NSString stringWithFormat:@"%s", uvDestPlane]);
    NSLog(@"uv %@", [NSString stringWithFormat:@"%s", uv]);
    
    memcpy(uvDestPlane, uv, width * height/2);
    
    NSLog(@"2 uvDestPlane %@", [NSString stringWithFormat:@"%s", uvDestPlane]);
    
    
    if(result == kCVReturnSuccess && pixelBuffer != NULL) {
        
        
        /*
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        size_t r = CVPixelBufferGetBytesPerRow(pixelBuffer);
        size_t bytesPerPixel = r/width;
        
        unsigned char *buffer = CVPixelBufferGetBaseAddress(pixelBuffer);
        
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        
        CGContextRef c = UIGraphicsGetCurrentContext();
        
        unsigned char* data = CGBitmapContextGetData(c);
        if (data != NULL) {
            size_t maxY = height;
            for(int y = 0; y<maxY; y++) {
                for(int x = 0; x<width; x++) {
                    size_t offset = bytesPerPixel*((width*y)+x);
                    data[offset] = buffer[offset];     // R
                    data[offset+1] = buffer[offset+1]; // G
                    data[offset+2] = buffer[offset+2]; // B
                    data[offset+3] = buffer[offset+3]; // A
                }
            }
        } 
        img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
         */
    }
    
    if (result != kCVReturnSuccess) {
        DDLogWarn(@"Unable to create cvpixelbuffer %d", result);
        NSLog(@"Unable to create cvpixelbuffer %d", result);
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    free(uv);
    
    
    CIImage *image = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:@{ (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) }];
    
    if(self.videoEffect){
        image = [self.videoEffect applyEffectTo:image];
    }
    
    
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:image fromRect:CGRectMake(0, 0, width, height)];
    
    //out -> videoImage
    
    img = [[UIImage alloc] initWithCGImage:videoImage scale:1.0 orientation:UIImageOrientationLeftMirrored];
    
    //img = [self imageFromSampleBuffer:pixelBuffer];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self.cameraImageView.hidden = NO;
        self.smallView.hidden = NO;
        [self.cameraImageView setImage:img];
    });
    
    CGImageRelease(videoImage);
    CVPixelBufferRelease(pixelBuffer);
}

# pragma mark - IMAGE CAPTURED

-(void)imageCaptured:(CIImage *)ciimage{
    
    //add mask first
    if(self.maskEffect != nil){
        ciimage = [self.maskEffect getCIImageFrom:ciimage];
    }
    
    //get CGImageRef from CII, cose [ciimage CGImage] is nil
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef inImage = [temporaryContext createCGImage:ciimage fromRect:CGRectMake(0, 0, ciimage.extent.size.width, ciimage.extent.size.height)];
    
    //apply effect
    if(self.videoEffect != nil){
        inImage = [self.videoEffect getRefWithEffectFrom:inImage];
    }
    
    //create UIImage
    
    UIImageOrientation orientation;
    if(self.cameraDelegate.isFront){
        orientation = UIImageOrientationLeftMirrored;
    }else{
        orientation = UIImageOrientationRight;
    }
    UIImage *outImage = [UIImage imageWithCGImage:inImage scale:1.0 orientation:orientation];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self.cameraImageView.hidden = NO;
        [self.cameraImageView setImage:outImage];
    });
    
    
    //OUT to source
    
    // Create the bitmap context
    CGContextRef cgctx = CreateARGBBitmapContext(inImage);
    if (cgctx == NULL){
        NSLog(@"----> %@", @"ERROR creating context");
        return;
    }
    
    // Get image width, height. We'll use the entire image.
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    void *data = CGBitmapContextGetData (cgctx);
    if (data != NULL) {
        // **** You have a pointer to the image data ****
        @autoreleasepool {
            [agoraSource DeliverFrame:data width:960 height:540 cropLeft:0 cropTop:0 cropRight:0 cropBottom:0 rotation:90 timeStamp:([[NSDate date] timeIntervalSince1970]* 1000) format:4];
        }
        
    }
    
    // When finished, release the context
    CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data){
        free(data);
    }
    
    CGImageRelease(inImage);
}


CGContextRef CreateARGBBitmapContext (CGImageRef inImage)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    long             bitmapByteCount;
    long             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = pixelsWide * 4;
    bitmapByteCount     = bitmapBytesPerRow * pixelsHigh;
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);//
    
    //kCGColorSpaceExtendedSRGB
    
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedLast);
    
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

//not used
- (NSArray*)getRGBAsFromImage:(UIImage*)image atX:(int)x andY:(int)y count:(int)count
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
    for (int i = 0 ; i < count ; ++i)
    {
        CGFloat alpha = ((CGFloat) rawData[byteIndex + 3] ) / 255.0f;
        CGFloat red   = ((CGFloat) rawData[byteIndex]     ) / alpha;
        CGFloat green = ((CGFloat) rawData[byteIndex + 1] ) / alpha;
        CGFloat blue  = ((CGFloat) rawData[byteIndex + 2] ) / alpha;
        byteIndex += bytesPerPixel;
        
        UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [result addObject:acolor];
    }
    
    free(rawData);
    
    return result;
}


//after check permissions
-(void)showMe{
    
    self.isMeShowed = YES;
    
    [self.cameraDelegate startCamera];
    agoraSource = [[AgoraVideoSource alloc] init];
    [agoraSource Attach];
    
    //AGORA
    [self.agoraKit setVideoProfile:AgoraRtc_VideoProfile_480P_9 swapWidthAndHeight: false];
    
    self.effectsButton.enabled = YES;
    self.cameraButton.enabled = YES;
    
    [self checkLogin];
}

-(void)checkMicPermission{
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    if(audioStatus == AVAuthorizationStatusAuthorized) { // authorized
        [self checkRules];
    }else if(audioStatus == AVAuthorizationStatusDenied){ // denied
        [self showSettingsError:@"Нам нужно включить ваш микрофон.\nПожалуйста разрешите доступ в Настройках."];
    }else if(audioStatus == AVAuthorizationStatusRestricted){ // restricted
        [self showError:@"Критическая ошибка.\nДоступ к вашему микрофону заблокирован."];
    }else if(audioStatus == AVAuthorizationStatusNotDetermined){ // not determined
        [self askMicPermission];
    }
}

-(void)askMicPermission{
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        if(granted){
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self checkRules];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self checkMicPermission];
            });
        }
        
    }];
}

-(void)checkRules{
    
    BOOL rules = [DataManager loadRules];
    
    if(!rules){
        [self showRulesPopup];
    }else{
        //short way
        //[self startSearching];
        
        [self checkSubscription];
    }
}


-(void)checkSubscription{
    
    if([self.user.male intValue] == 1){
        //guys
        
        if([StoreManager sharedInstance].status == Unchecked){
            [SVProgressHUD show];
            
            [[StoreManager sharedInstance] checkSubValid:^(BOOL isSubValid, BOOL needOnline) {
                [SVProgressHUD dismiss];
                
                if(isSubValid){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self startSearching];
                    });
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(!needOnline){
                            [self showBuyPopup];
                        }else{
                            [self showError:@"Требуется подключение к интернету"];
                        }
                    });
                }
            }];
        }else{
            [self startSearching];
        }
    }else{
        //ladies
        [self startSearching];
    }
}

-(void)startSearching{
    
    self.chatStatus = ChatSearching;
    [self startCounterFor:TimerSearch];
    
    NSDictionary *settings = [DataManager loadFilters];
    if(!settings){
        settings = @{@"geo":@0, @"sex":@1, @"men":@1, @"women":@1, @"minAge":@18.0, @"maxAge":@60.0};
        DDLogInfo(@"new settings %@", settings);
    }
    
    NSDictionary *data = @{@"male":settings[@"men"], @"year_min":settings[@"minAge"], @"year_max":settings[@"maxAge"], @"location":@{@"lon":LOCATION.lon,@"lat":LOCATION.lat}};
    
    [API callMethod:@"search" withData:data];
    
    //call startChatWithChatId
}
    
-(void)stopSearching{
    self.chatStatus = ChatStopped;
    [self stopCounter];
}

#pragma mark - COUNTER

-(void)timerLabel:(MZTimerLabel*)timerLabel finshedCountDownTimerWithTime:(NSTimeInterval)countTime{
    
    if(timerLabel == mainTimer){
        
        //search of user
        if(self.chatStatus == ChatSearching){
            [self showError:@"К сожалению подходящий собеседник не найден.\nПопробуйте ещё раз."];
            
        //decision waiting
        }else if(self.chatStatus == ChatDecisionWaiting){
            [self showSuccessPopup];
        }
        
        [self stopSearching];
    }else if(timerLabel == chatTimer){
        [self stopChat];
        [self showResultPopup:TimeOut];
    }
    
}

-(void)startCounterFor:(TimerType)type{
    if (type == TimerSearch) {
        self.timerTitleLabel.text = @"Ищем собеседника";
        [mainTimer setCountDownTime:SearchTimeInterval];
    }else if (type == TimerDecision) {
        self.timerTitleLabel.text = @"Ждём решения собеседника";
        [mainTimer setCountDownTime:DecisionTimeInterval];
    }
    
    [mainTimer reset];
    [mainTimer start];
    
    self.timerView.hidden = false;
}

-(void)stopCounter{
    [mainTimer pause];
    self.timerView.hidden = true;
}

#pragma mark - START CHAT

-(void)startChatWithChatId:(NSString *)chatId{
    
    self.connectingView.hidden = NO;
    [self stopCounter];
    self.chatStatus = ChatConnecting;
    
    [self.agoraKit joinChannelByKey:nil channelName:chatId info:nil uid:0 joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
        
        [self.agoraKit setEnableSpeakerphone:YES];
        [UIApplication sharedApplication].idleTimerDisabled = YES; //do not sleep
    }];
}

-(void)chatStoppedBy:(NSUInteger)uid{
    
    [self stopChat];
    if([mainTimer getTimeRemaining] < 10){
        [self showResultPopup:TimeOut];
    }else{
        [self showResultPopup:InterruptedByOpponent];
    }
    
}

#pragma mark Chat Stopped

-(void)stopChat{
    self.chatStatus = ChatStopped;
    
    [self.agoraKit leaveChannel:^(AgoraRtcStats *stat) {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        
        self.smallCameraImageView.image = nil;
        
        self.bigCameraImageView.image = nil;
        self.cameraImageView = self.bigCameraImageView;
        
        self.bigCameraImageView.hidden = NO;
        
        self.smallView.hidden = YES;
        self.connectingView.hidden = YES;
    }];
}

//hide snapshot with big video
-(void)hideBigCamera{
    self.mainView.hidden = YES;
}

#pragma mark Chat Started

-(void)chatStartedWith:(NSUInteger)uid{
    self.chatStatus = ChatStarted;
    
    //me
    
    self.bigCameraImageView.image = nil;
    self.cameraImageView = self.smallCameraImageView;
    
    //he
    AgoraRtcVideoCanvas *bigCanvas = [[AgoraRtcVideoCanvas alloc] init];
    bigCanvas.uid = uid;
    bigCanvas.view = self.mainView;
    bigCanvas.renderMode = AgoraRtc_Render_Fit;
    [self.agoraKit setupRemoteVideo:bigCanvas];
    
    self.bigCameraImageView.hidden = YES;
    self.mainView.hidden = NO;
    self.smallView.hidden = NO;
    self.connectingView.hidden = YES;
}


#pragma mark -
#pragma mark AgoraDelegate

- (void)rtcEngineConnectionDidInterrupted:(AgoraRtcEngineKit *)engine{
    NSLog(@"AGORA: rtcEngineConnectionDidInterrupted");
}

- (void)rtcEngineConnectionDidLost:(AgoraRtcEngineKit *)engine{
    NSLog(@"AGORA: rtcEngineConnectionDidLost");
}


- (void)rtcEngine:(AgoraRtcEngineKit *)engine localVideoStats:(AgoraRtcLocalVideoStats*)stats{
    NSLog(@"AGORA: localVideoStats %ld", (long)stats.sentFrameRate);
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurWarning:(AgoraRtcWarningCode)warningCode{
    NSLog(@"AGORA: didOccurWarning %ld", (long)warningCode);
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurError:(AgoraRtcErrorCode)errorCode{
    NSLog(@"AGORA: didOccurError %ld", (long)errorCode);
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstLocalVideoFrameWithSize:(CGSize)size elapsed:(NSInteger)elapsed{
    NSLog(@"AGORA: firstLocalVideoFrameWithSize %f", size.height);
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size: (CGSize)size elapsed:(NSInteger)elapsed {
    
    NSLog(@"AGORA: firstRemoteVideoDecodedOfUid %li", (unsigned long)uid);
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed{
    NSLog(@"AGORA: didJoinedOfUid %li", (unsigned long)uid);
    
    [self chatStartedWith:uid];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraRtcUserOfflineReason)reason{
    
    NSLog(@"AGORA: didOfflineOfUid %li", (unsigned long)uid);
    
    [self chatStoppedBy:uid];
}

#pragma mark - Chat Decision

-(void)sendChatSuccess{
    
    
    self.chatStatus = ChatDecisionWaiting;
    [self startCounterFor:TimerDecision];
    
    [API callMethod:@"approve" withData:nil];
}

-(void)sendChatRejectWithReason:(int)reason{
    [self hideBigCamera];
    
    NSNumber *reasonNumber = [NSNumber numberWithInt:reason];
    NSDictionary *userInfo = @{@"reason":reasonNumber,@"message":@""};

    [API callMethod:@"reject" withData:userInfo];
}

 
#pragma mark - BUTTONS

- (IBAction)menuTapped:(id)sender {
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (IBAction)filterTapped:(id)sender {
    [self.sideMenuViewController presentRightMenuViewController];
}

- (IBAction)effectsTapped:(id)sender {
    
    if(self.bottomBarCons.constant > 0){
        [self.effectsButton setImage:[UIImage imageNamed:@"ic_effects_up"] forState:UIControlStateNormal];
        CGFloat start = self.bottomBarCons.constant;
        [INTUAnimationEngine animateWithDuration:0.4
                                           delay:0.0
                                          easing:INTUEaseOutCubic
                                         options:INTUAnimationOptionNone
                                      animations:^(CGFloat progress) {
                                          self.bottomBarCons.constant = INTUInterpolateCGFloat(start, 0, progress);
                                          [self.view layoutIfNeeded];
                                      }
                                      completion:nil];
    }else{
        [self.effectsButton setImage:[UIImage imageNamed:@"ic_effects_down"] forState:UIControlStateNormal];
        [INTUAnimationEngine animateWithDuration:0.4
                                           delay:0.0
                                          easing:INTUEaseOutCubic
                                         options:INTUAnimationOptionNone
                                      animations:^(CGFloat progress) {
                                          self.bottomBarCons.constant = INTUInterpolateCGFloat(0, self.effectsView.frame.size.height, progress);
                                      }
                                      completion:nil];
    }
    
}

- (IBAction)cameraTapped:(id)sender {
    [self.cameraDelegate switchCamera];
}

- (IBAction)filtersTapped:(id)sender {
    self.nowEffect = Filters;
    [_collectionView reloadData];
}

- (IBAction)masksTapped:(id)sender {
    self.nowEffect = Masks;
    [_collectionView reloadData];
}


#pragma mark - START BUTTON TAP

- (IBAction)startButtonTapped:(id)sender {
    if(_chatStatus == ChatReady){
        [self askCameraPermission];
    }else if(_chatStatus == ChatStopped){
        [self checkMicPermission];
    }else if(_chatStatus == ChatSearching){
        [API callMethod:@"searchStop" withData:nil];
        [self stopSearching];
    }else if(_chatStatus == ChatConnecting){
        [self stopChat];
    }else if(_chatStatus == ChatStarted){
        [self stopChat];
        [self showResultPopup:InterruptedByMe];
    }else if(_chatStatus == ChatLoginNeeded){
        [self askLogin];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSInteger value = [[change valueForKey:@"new"] integerValue];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if ([keyPath isEqualToString:@"chatStatus"])
        {
            [self setChatBehavior:value];
        }else if([keyPath isEqualToString:@"apiStatus"]){
            [self setApiBehavior:value];
        }
    });
    
}

-(void)setApiBehavior:(NSInteger)value{
    switch (value) {
        case ApiConnected:
            _startButton.alpha = 1;
            _startButton.enabled = true;
            [self setStatus:@"Connected"];
            break;
        case ApiDisconnected:
            _startButton.alpha = 0.5;
            _startButton.enabled = false;
            self.onlineLabel.text = @"Connection Error";
            [self setStatus:@"Disconnected"];
            break;
        case ApiReconnect:
            [self setStatus:@"Reconnect"];
            break;
        case ApiError:
            _startButton.alpha = 0.5;
            _startButton.enabled = false;
            self.onlineLabel.text = @"Connection Error";
            
            [self setStatus:@"Error"];
            
            if(self.chatStatus == ChatSearching){
                [API callMethod:@"searchStop" withData:nil];
                [self stopSearching];
            }
            
            break;
        default:
            break;
    }
}

-(void)setChatBehavior:(NSInteger)value{
    NSString *title = @"";
    
    [self.startButton setBackgroundColor:[UIColor colorWithRed:1.0 green:0.8 blue:0.2 alpha:1]];
    
    switch (value) {
        case ChatIniting:
            title = @"Подождите";
            [self.startButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.2]];
            break;
        case ChatDecisionWaiting:
            title = @"Подождите";
            [self.startButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.2]];
            break;
        case ChatReady:
            title = @"Включить";
            [API callMethod:@"getStat" withData:nil];
            break;
        case ChatStopped:
            title = NSLocalizedString(@"searchButtonLabel", nil); //Искать
            self.chatUpperBar.hidden = YES;
            self.mainUpperBar.hidden = NO;
            [chatTimer pause];
            [API callMethod:@"getStat" withData:nil];
            break;
        case ChatSearching:
            self.mainUpperBar.hidden = true;
            title = @"Отмена";
            [self.startButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.2]];
            break;
        case ChatConnecting:
            title = @"Отмена";
            [self.startButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.2]];
            break;
        case ChatStarted:
            self.chatUpperBar.hidden = NO;
            [chatTimer setCountDownTime:180];
            [chatTimer reset];
            [chatTimer start];
            title = @"Стоп";
            [self.startButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.2]];
            break;
        case ChatLoginNeeded:
            title = @"Войти";
            [API callMethod:@"getStat" withData:nil];
            break;
        default:
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.startButton setTitle:title forState:UIControlStateNormal];
    });
}


#pragma mark - COLLECTION VIEW DELEGATE

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EffectCell" forIndexPath:indexPath];
    
    UIImage *image;
    if(self.nowEffect == Filters){
        image = [UIImage imageNamed:@"ic_filter"];
    }else{
        image = [UIImage imageNamed:[NSString stringWithFormat:@"masks_%li", (long)indexPath.row]];
    }
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
    iv.image = image;
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell.contentView addSubview:iv];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell setSelected:YES];
    
    if(self.nowEffect == Filters){
        [self addEffect:[self.filtersArray[indexPath.row] intValue]];
    }else{
        [self addMask:[self.masksArray[indexPath.row] intValue]];
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if(self.nowEffect == Filters){
        return self.filtersArray.count;
    }else{
        return self.masksArray.count;
    }
}

#pragma mark ADD EFFECT

-(void)addMask:(MaskType)mid{
    self.maskEffect = [[MaskEffect alloc] initWithType:mid];
}

#pragma mark ADD EFFECT

-(void)addEffect:(EffectType)eid{
    self.videoEffect = [[VideoEffect alloc] initWithType:eid];
}

#pragma mark - POPUPS

-(void)showFailPopup{
    [self stopSearching];
    
    self.bottomBarView.hidden = YES;
    
    PopupDialog *popup = [[PopupDialog alloc] initWithTitle:nil
                                                    message:nil
                                                      image:[UIImage imageNamed:@"img_fail"]
                                            buttonAlignment:UILayoutConstraintAxisVertical
                                            transitionStyle:PopupDialogTransitionStyleBounceUp
                                           gestureDismissal:NO
                                                 completion:nil];
    
    DefaultButton *b = [[DefaultButton alloc] initWithTitle:@"Попробовать ещё раз" height:kPopupButtonHeight dismissOnTap:YES action:^{
        self.bottomBarView.hidden = NO;
     }];
    
    b.titleColor = [UIColor whiteColor];
    b.buttonColor = colorFromInteger(0xFFB61C);
    
    [popup addButtons: @[b]];
    
    [self presentViewController:popup animated:YES completion:nil];
}

-(void)showSuccessPopup{
    [self stopSearching];
    
    self.bottomBarView.hidden = YES;
    PopupDialog *popup = [[PopupDialog alloc] initWithTitle:nil
                                                    message:nil
                                                      image:[UIImage imageNamed:@"img_win"]
                                            buttonAlignment:UILayoutConstraintAxisVertical
                                            transitionStyle:PopupDialogTransitionStyleBounceUp
                                           gestureDismissal:NO
                                                 completion:nil];
    
    DefaultButton *b = [[DefaultButton alloc] initWithTitle:NSLocalizedString(@"continueButtonLabel", nil) height:kPopupButtonHeight dismissOnTap:YES action:^{
        self.bottomBarView.hidden = NO;
    }];
    
    CancelButton *cancel = [[CancelButton alloc] initWithTitle:@"Открыть социальный профиль" height:kPopupButtonHeight dismissOnTap:YES action:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.chat.url]];
        self.bottomBarView.hidden = NO;
    }];
    
    [popup addButtons: @[b, cancel]];
    
    [self presentViewController:popup animated:YES completion:nil];
}

-(void)showBuyPopup{
    NSString *message = @"Сейчас вы будете перенаправлены на подключение подписки с бесплатным периодом.\n\nЭто значит, что, оформив подписку, вы получите бесплатный доступ на 1 неделю, а только потом с вашего счёта будут списаны деньги за следующую неделю. В любой момент в течение 7 дней подписку можно отключить, чтобы не платить вообще ничего.\n\nСтоимость составляет 3 доллара — цена чашки кофе в кафе.";
    PopupDialog *popup = [[PopupDialog alloc] initWithTitle:@"Подписка"
                                                    message:message
                                                      image:nil
                                            buttonAlignment:UILayoutConstraintAxisVertical
                                            transitionStyle:PopupDialogTransitionStyleBounceUp
                                           gestureDismissal:NO
                                                 completion:nil];
    
    ((PopupDialogDefaultViewController *)popup.viewController).standardView.messageTextAlignment = NSTextAlignmentLeft;
    
    DefaultButton *b = [[DefaultButton alloc] initWithTitle:@"Вперёд" height:kPopupButtonHeight dismissOnTap:YES action:^{
        [self buySubscription];
    }];
    
    b.titleColor = [UIColor whiteColor];
    b.buttonColor = colorFromInteger(0x24BF5F);
    
    [popup addButtons: @[b]];
    
    [self presentViewController:popup animated:YES completion:nil];
}

-(void)buySubscription{
    [[StoreManager sharedInstance] buy:0 withBlock:^(SKPaymentTransaction *data, NSError *error) {
        if(!error){
            //force cheking
            [[StoreManager sharedInstance] checkSubscription];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self startSearching];
            });
            
        }else{
            //cancel make it also
            [self showError:@"Ошибка покупки подписки, попробуйте ещё раз."];
        }
    }];
}

-(void)showRulesPopup{
    NSString *message = @"Пожалуйста, никаких сексуальных действий;\n\nНикакого обнажённого тела более того, что обычно принято;\n\nНикаких слов, которые могут обидеть или задеть собеседника;\n\nБудьте вежливы и дружелюбны;\n\nЗаинтересуйте и рассмешите собеседника.\n\nМы проверяем автоматическими алгоритмами все трансляции, идущие в эфире. Доступ будет заблокирован навсегда при нарушении правил.\nУдачи!";
    PopupDialog *popup = [[PopupDialog alloc] initWithTitle:@"Правила очень простые:"
                                                    message:message
                                                      image:nil
                                            buttonAlignment:UILayoutConstraintAxisVertical
                                            transitionStyle:PopupDialogTransitionStyleBounceUp
                                           gestureDismissal:NO
                                                 completion:nil];
    
    ((PopupDialogDefaultViewController *)popup.viewController).standardView.messageTextAlignment = NSTextAlignmentLeft;
    
    DefaultButton *b = [[DefaultButton alloc] initWithTitle:@"Понятно" height:kPopupButtonHeight dismissOnTap:YES action:^{
        [DataManager saveRules:YES];
        [self startSearching];
    }];
    b.titleColor = [UIColor whiteColor];
    b.buttonColor = colorFromInteger(0x24BF5F);
    
    [popup addButtons: @[b]];
    
    [self presentViewController:popup animated:YES completion:nil];
}

-(void)showDecisionPopup{
    
    
    PopupDialog *popup = [[PopupDialog alloc] initWithTitle:@"Почему вы не хотите продолжить общение?"
                                                    message:@""
                                                      image:nil
                                            buttonAlignment:UILayoutConstraintAxisVertical
                                            transitionStyle:PopupDialogTransitionStyleBounceUp
                                           gestureDismissal:YES
                                                 completion:nil];
    
    CancelButton *cancel = [[CancelButton alloc] initWithTitle:@"Без ответа" height:kPopupButtonHeight dismissOnTap:YES action:^{
        [self sendChatRejectWithReason:0];
    }];
    
    DefaultButton *v1 = [[DefaultButton alloc] initWithTitle:@"Просто не нравится" height:kPopupButtonHeight dismissOnTap:YES action:^{
        [self sendChatRejectWithReason:1];
    }];
    
    DefaultButton *v2 = [[DefaultButton alloc] initWithTitle:@"Не поняли друг друга" height:kPopupButtonHeight dismissOnTap:YES action:^{
        [self sendChatRejectWithReason:2];
    }];
    
    DefaultButton *v3 = [[DefaultButton alloc] initWithTitle:@"Некачественная связь" height:kPopupButtonHeight dismissOnTap:YES action:^{
        [self sendChatRejectWithReason:3];
    }];
    
    DefaultButton *v4 = [[DefaultButton alloc] initWithTitle:@"Грубость" height:kPopupButtonHeight dismissOnTap:YES action:^{
        [self sendChatRejectWithReason:4];
    }];
    
    DefaultButton *v5 = [[DefaultButton alloc] initWithTitle:@"Непристойности" height:kPopupButtonHeight dismissOnTap:YES action:^{
        [self sendChatRejectWithReason:5];
    }];
    
    [popup addButtons: @[v1,v2,v3,v4,v5,cancel]];
    
    [self presentViewController:popup animated:YES completion:nil];
}

-(void)showResultPopup:(EndReason)reason{
    [self hideUI];
    [self.endPopup showWithReason:reason];
}

//error

-(void)showSettingsError:(NSString *)text{
    PopupDialog *popup = [[PopupDialog alloc] initWithTitle:@"Ошибка"
                                                    message:text
                                                      image:nil
                                            buttonAlignment:UILayoutConstraintAxisHorizontal
                                            transitionStyle:PopupDialogTransitionStyleBounceUp
                                           gestureDismissal:YES
                                                 completion:nil];
    
    DefaultButton *v1 = [[DefaultButton alloc] initWithTitle:@"Настройки" height:kPopupButtonHeight dismissOnTap:YES action:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    
    [popup addButtons: @[v1]];
    [self presentViewController:popup animated:YES completion:nil];
}

-(void)showError:(NSString *)text{
    PopupDialog *popup = [[PopupDialog alloc] initWithTitle:@"Ошибка"
                                                    message:text
                                                      image:nil
                                            buttonAlignment:UILayoutConstraintAxisHorizontal
                                            transitionStyle:PopupDialogTransitionStyleBounceUp
                                           gestureDismissal:YES
                                                 completion:nil];
    
    CancelButton *cancel = [[CancelButton alloc] initWithTitle:@"Закрыть" height:kPopupButtonHeight dismissOnTap:YES action:^{
       
    }];
    
    [popup addButtons: @[cancel]];
    [self presentViewController:popup animated:YES completion:nil];
}

-(void)askLogin{
    [self.loginPopup show];
}


#pragma mark - INTRO

-(void)showIntro{
    self.introViewController = [IntroViewController new];
    [self presentViewController:self.introViewController animated:true completion:nil];
}


- (UIImage *)capturedView:(UIView *)shotView withBounds:(CGRect)bounds andScale:(int)upScale
{
    
    if(shotView == nil){
        return nil;
    }
    
    //calculate scaling
    float effectiveScale = 1 / upScale; //2 times bigger then actual frame size
    
    CGSize captureSize = CGSizeMake(shotView.bounds.size.width / effectiveScale, shotView.bounds.size.height / effectiveScale);
    
    //create snapshop from shotView
    UIGraphicsBeginImageContextWithOptions(captureSize, NO, 0.0);
    //get context
    CGContextRef context = UIGraphicsGetCurrentContext();
    //render in context
    CGContextScaleCTM(context, 1/(effectiveScale*[UIScreen mainScreen].scale), 1/(effectiveScale*[UIScreen mainScreen].scale));
    
    CALayer *shotLayer = shotView.layer;
    
    if(shotLayer == nil){
        return nil;
    }
    
    [shotLayer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(img == nil){
        return nil;
    }
    
    //crop
    CGRect cropRect = CGRectMake(0, 0, bounds.size.width*upScale, bounds.size.height*upScale);
    
    CGImageRef imageUncroppedRef = [img CGImage];
    
    if(imageUncroppedRef == nil){
        return nil;
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(imageUncroppedRef, cropRect);
    if(imageRef == nil){
        return nil;
    }
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    if(croppedImage == nil){
        return nil;
    }
    
    return croppedImage;
}

//ui

-(void)showUI{
    self.bottomBarView.hidden = NO;
    self.mainUpperBar.hidden = NO;
    self.effectsView.hidden = NO;
}

-(void)hideUI{
    self.bottomBarView.hidden = YES;
    self.mainUpperBar.hidden = YES;
    self.effectsView.hidden = YES;
}

#pragma mark - SEGUE PREPARATION

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ShowRegistration"])
    {
        RegisterViewController *controller = [segue destinationViewController];
        [controller initUser:self.user];
    }
}

-(void)didReceiveMemoryWarning{
    NSLog(@"didReceiveMemoryWarning didReceiveMemoryWarning didReceiveMemoryWarning");
}


@end
