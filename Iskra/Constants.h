//
//  Constants.h
//  vchat
//
//  Created by Alexey Fedotov on 28/09/16.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

FOUNDATION_EXPORT int ddLogLevel;
FOUNDATION_EXPORT BOOL ddLogEnabled;

#define kPopupButtonHeight 50
#define colorFromInteger(Color) [UIColor colorWithRed:((Color & 0xFF0000) >> 16) / 255.0 green:((Color & 0xFF00) >> 8) / 255.0 blue:(Color & 0xFF) / 255.0 alpha:1]

typedef NS_ENUM(NSInteger, ChatStatus) {
    ChatIniting,
    ChatReady,
    ChatStopped,
    ChatSearching,
    ChatConnecting,
    ChatStarted,
    ChatLoginNeeded,
    ChatDecisionWaiting
};

typedef NS_ENUM(NSInteger, EndReason) {
    TimeOut,
    ConnectionError,
    InterruptedByMe,
    InterruptedByOpponent
};

@interface Constants : NSObject

    //notifications
    extern NSString * const PopupNotification;
    extern NSString * const LoadingProgressNotification;
    extern NSString * const ConfigLoadedNotification;
    extern NSString * const LoginSuccessNotification;
    extern NSString * const LoginFailNotification;
    extern NSString * const YesEndNotification;
    extern NSString * const NoEndNotification;
    extern NSString * const UserCompleteNotification;

    extern NSString * const FirstPathUrl;

    extern NSString * const VkontakteAppId;
    
    extern NSString * const AdTypeFacebook;
    extern NSString * const AdTypeAdmob;
    extern NSString * const AdTypeRewarded;

    extern NSString * const Vkontakte;
    extern NSString * const Facebook;

    extern NSTimeInterval const SearchTimeInterval;
    extern NSTimeInterval const DecisionTimeInterval;
    
@end
