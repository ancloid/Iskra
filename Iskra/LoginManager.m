//
//  LoginManager.m
//  Iskra
//
//  Created by Alexey Fedotov on 07/10/2016.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import "LoginManager.h"

@implementation LoginManager

+ (instancetype)sharedController
{
    static LoginManager *__sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedController = [[LoginManager alloc] init];
    });
    return __sharedController;
}

-(id)init{
    if((self = [super init])) {
        fbLoginManager = [[FBSDKLoginManager alloc] init];
        [[VKSdk initializeWithAppId:VkontakteAppId] registerDelegate:self];
        [[VKSdk instance] setUiDelegate:self];
        _isFbSigned = false;
        _isVkSigned = false;
    }
    return self;
}

-(void)initWithRoot:(UIViewController *)rootValue{
    root = rootValue;
}

- (void)logOutFrom:(NSString *)platform{
    if ([platform isEqualToString:Facebook]) {
        [self fbLogout];
    }else if ([platform isEqualToString:Vkontakte]) {
        [self vkLogout];
    }
}

- (void)loginTo:(NSString *)platform withBlock:(LoginBlock)action{
    _actionBlock = action;
    
    if ([platform isEqualToString:Facebook]) {
        if (!_isFbSigned) {
            [self fbLogin];
        }else{
            [self fbCheckProfile];
        }
    }else if ([platform isEqualToString:Vkontakte]) {
        if (!_isVkSigned) {
            [self vkLogin];
        }else{
            [self vkCheckProfile];
        }
    }
}

- (void)checkFor:(NSString *)platform{
    
    if ([platform isEqualToString:Facebook]) {
        if ([FBSDKAccessToken currentAccessToken]) {
            _isFbSigned = true;
        }
    }else if ([platform isEqualToString:Vkontakte]) {
        [VKSdk wakeUpSession:@[VK_PER_NOHTTPS, VK_PER_EMAIL] completeBlock:^(VKAuthorizationState state, NSError *error) {
            if (state == VKAuthorizationAuthorized) {
                _isVkSigned = true;
            } else if (error) {
                //[self endWith:false andData:error];
                [self showError:error.localizedDescription];
            }
        }];
    }
}

//VKONTAKTE

-(void)vkLogin{
    [VKSdk authorize:@[VK_PER_NOHTTPS, VK_PER_EMAIL]];
}

//VKSDKDELEGATE
- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result{
    if (result.token) {
        _isVkSigned = true;
        NSString *email = @"";
        if(result.token.email != NULL){
            email = result.token.email;
        }
        [self vkCheckProfile];
    }else{
        [self endWith:false andData:nil];
    }
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken{
    [self loginTo:Vkontakte withBlock:nil];
}

- (void)vkSdkUserAuthorizationFailed{
    [self endWith:false andData:nil];
}

//VKSdkUIDelegate

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError{
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:root];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller{
    [root presentViewController:controller animated:YES completion:nil];
}


///

-(void)vkLogout {
    [VKSdk forceLogout];
    _isVkSigned = false;
}

-(void)vkCheckProfile{
    [self getVkUser];
}

-(void)getVkUser{
    VKRequest *request = [[VKApi users] get:@{ VK_API_FIELDS : @"id,first_name,last_name,bdate,domain,sex"}];
    request.requestTimeout = 10;
    
    [request executeWithResultBlock: ^(VKResponse *response) {
        
        if ([[response json] isKindOfClass:[NSArray class]]) {
            NSMutableArray* responseArr = [response json];
            
            NSLog(@"getVkUser: %@", responseArr);
            [self endWith:true andData:[responseArr objectAtIndex:0]];
        }
    } errorBlock: ^(NSError *error) {
        NSLog(@"Error: %@", error);
        
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        }else {
            [self showError:error.description];
            [self endWith:false andData:nil];
        }
    }];
}

//FACEBOOK

-(void)fbLogin {
    [fbLoginManager logInWithReadPermissions:@[@"public_profile",@"user_birthday"] fromViewController:root handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            [self showError:error.description];
            [self endWith:false andData:nil];
        } else if (result.isCancelled) {
            [self endWith:false andData:nil];
        } else {
            _isFbSigned = true;
            [self fbCheckProfile];
        }
    }];
}

-(void)fbCheckProfile {
    [self getFbUser];
}

-(void)fbLogout {
    [fbLoginManager logOut];
    _isFbSigned = false;
}

-(void)getFbUser{
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me" parameters:@{ @"fields" : @"id,first_name,last_name,birthday,gender,link"}]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             [self endWith:true andData:result];
         }else{
             [self showError:error.description];
             [self endWith:false andData:nil];
         }
     }];
}


//OTHERS

-(void)endWith:(BOOL)result andData:(NSDictionary *)data{
    if (_actionBlock){
        _actionBlock(result, data);
        _actionBlock = nil;
    }
}

-(void)showError:(NSString *)error{
    NSDictionary *userInfo = @{@"text" : error};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowError" object:self userInfo:userInfo];
}

@end



