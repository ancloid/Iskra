//
//  AppDelegate.m
//  vchat
//
//  Created by Alexey Fedotov on 19/08/16.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
@import VK_ios_sdk;
#import <OneSignal/OneSignal.h>
#import "StoreManager.h"
#import "RMStore.h"
#import "RMStoreKeychainPersistence.h"
#import "RMStoreAppReceiptVerificator.h"

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
    //ONE SIGNAL
   [OneSignal initWithLaunchOptions:launchOptions appId:@"8987a661-4036-412d-9606-e4c388a61a77" handleNotificationReceived:^(OSNotification *notification) {
       NSLog(@"Received Notification - %@", notification.payload.notificationID);
   } handleNotificationAction:^(OSNotificationOpenedResult *result) {
        // This block gets called when the user reacts to a notification received
   } settings:@{kOSSettingsKeyInFocusDisplayOption : @(OSNotificationDisplayTypeInAppAlert), kOSSettingsKeyAutoPrompt : @NO}];
    
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
    //or for ios9
    //[VKSdk processOpenURL:url fromApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]];
    
    return YES;
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
