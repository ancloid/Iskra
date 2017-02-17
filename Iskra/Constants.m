//
//  Constants.m
//  vchat
//
//  Created by Alexey Fedotov on 28/09/16.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import "Constants.h"

@implementation Constants

    int ddLogLevel = DDLogLevelVerbose;
    BOOL ddLogEnabled = true;

    //notifications
    NSString * const PopupNotification = @"PopupNotification";
    NSString * const LoadingProgressNotification = @"LoadingProgressNotification";
    NSString * const ConfigLoadedNotification = @"ConfigLoadedNotification";
    NSString * const LoginSuccessNotification = @"LoginSuccessNotification";
    NSString * const LoginFailNotification = @"LoginFailNotification";
    NSString * const YesEndNotification = @"YesEndNotification";
    NSString * const NoEndNotification = @"NoEndNotification";
    NSString * const UserCompleteNotification = @"UserCompleteNotification";

    NSString * const FirstPathUrl = @"http://webka.pics/webka/php/getconfig.php";

    NSString * const VkontakteAppId = @"5659563";

    //ad types
    NSString * const AdTypeFacebook = @"fb";
    NSString * const AdTypeAdmob = @"am";
    NSString * const AdTypeRewarded = @"re";

    NSString * const Vkontakte = @"vk";
    NSString * const Facebook = @"fb";

    NSTimeInterval const SearchTimeInterval = 300;
    NSTimeInterval const DecisionTimeInterval = 20;

@end
