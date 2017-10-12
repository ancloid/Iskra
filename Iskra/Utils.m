//
//  Utils.m
//  Iskra
//
//  Created by Alexey Fedotov on 19/08/16.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import "Utils.h"
//#import "SSKeychain.h"

@implementation Utils

+(NSString *) randomStringWithLength: (int) len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length])]];
    }
    
    return randomString;
}

+(NSString *)getUUID
{
    NSString *thisDeviceID;
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        thisDeviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }else{
        CFStringRef cfUuid = CFUUIDCreateString(NULL, CFUUIDCreate(NULL));
        thisDeviceID = (__bridge NSString *)cfUuid;
        CFRelease(cfUuid);
    }
    
    //save to keychain
    //NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    
    /*
    NSString *strApplicationUUID = [SSKeychain passwordForService:appName account:@"incoding"];
    if (strApplicationUUID == nil)
    {
        strApplicationUUID = thisDeviceID;
        [SSKeychain setPassword:strApplicationUUID forService:appName account:@"incoding"];
    }*/
    
    NSLog(@"UUID = %@", thisDeviceID);
    
    return thisDeviceID;
}

@end
