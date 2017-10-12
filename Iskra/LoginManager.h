//
//  LoginManager.h
//  Iskra
//
//  Created by Alexey Fedotov on 07/10/2016.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
@import VK_ios_sdk;

typedef void (^LoginBlock)(BOOL finished, NSDictionary *data);

@interface LoginManager : NSObject<VKSdkDelegate, VKSdkUIDelegate>{
    FBSDKLoginManager *fbLoginManager;
    UIViewController *root;
}

@property (nonatomic, copy) LoginBlock actionBlock;
@property (nonatomic) BOOL isFbSigned;
@property (nonatomic) BOOL isVkSigned;


+ (instancetype)sharedController;
- (void)initWithRoot:(UIViewController *)rootValue;
- (void)loginTo:(NSString *)platform withBlock:(LoginBlock)action;
- (void)logOutFrom:(NSString *)platform;
- (void)checkFor:(NSString *)platform;



@end
