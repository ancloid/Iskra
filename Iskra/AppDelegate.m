//
//  AppDelegate.m
//  Iskra
//
//  Created by Alexey Fedotov on 19/08/16.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
@import VK_ios_sdk;
#import "StoreManager.h"
#import "RMStore.h"
#import "RMStoreKeychainPersistence.h"
#import "RMStoreAppReceiptVerificator.h"
#import "DataManager.h"

@interface AppDelegate () {
    RMStoreAppReceiptVerificator *_receiptVerifier;
    RMStoreKeychainPersistence *_persistence;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //FACEBOOK
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    [self configureStore];
    [[StoreManager sharedInstance] start];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    [VKSdk processOpenURL:url fromApplication:sourceApplication];
    
    return YES;
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken{
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    if(![DATA writeData:hexToken withName:@"apnsToken"]){
        DDLogError(@"Error save token");
    }
    
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken - %@", hexToken);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)configureStore
{
    _receiptVerifier = [[RMStoreAppReceiptVerificator alloc] init];
    [RMStore defaultStore].receiptVerificator = _receiptVerifier;
    
    _persistence = [[RMStoreKeychainPersistence alloc] init];
    [RMStore defaultStore].transactionPersistor = _persistence;
}

@end
