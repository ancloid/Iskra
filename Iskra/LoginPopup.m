//
//  LoginPopup.m
//  Webka
//
//  Created by Alexey Fedotov on 21/08/15.
//  Copyright (c) 2015 Ancle Apps. All rights reserved.
//

#import "LoginPopup.h"
#import "NSString+EMAdditions.h"
#import "LoginManager.h"

#define kTitleToButtonVerticalSpace 50
#define kButtonVerticalSpace 15

@implementation LoginPopup

-(void)create{
    [super create];
    
    [self setSubTitle:NSLocalizedString(@"loginPopupTitle", nil)];
    //[self setHint:NSLocalizedString(@"hintAddTitle", nil)];
    
    fbButton = [self setupButtonWithTitle:NSLocalizedString(@"facebookButtonLabel", nil) andColor:colorFromInteger(0x3664a2) andTextColor:[UIColor whiteColor] andAction:@selector(fbTapped:)];
    vkButton = [self setupButtonWithTitle:NSLocalizedString(@"vkButtonLabel", nil) andColor:colorFromInteger(0x4D75A3)andTextColor:[UIColor whiteColor] andAction:@selector(vkTapped:)];
    //okButton = [self setupButtonWithTitle:NSLocalizedString(@"okButtonLabel", nil) andColor:[UIColor odnoklassnikiColor] andTextColor:[UIColor whiteColor] andAction:@selector(okTapped:)];
    emailButton = [self setupButtonWithTitle:NSLocalizedString(@"emailButtonLabel", nil) andColor:[UIColor greenColor] andTextColor:[UIColor whiteColor] andAction:@selector(emailTapped:)];
    
    //[self setImage:[UIImage imageNamed:@"icon_fb"] forButton:fbButton];
    //[self setImage:[UIImage imageNamed:@"icon_vk_new"] forButton:vkButton];
    //[self setImage:[UIImage imageNamed:@"icon_ok"] forButton:okButton];
    //[self setImage:[UIImage imageNamed:@"icons/ic_email"] forButton:emailButton];

    fbButton.y = subtitleLabel.y+subtitleLabel.height+kTitleToButtonVerticalSpace;
    vkButton.y = fbButton.y+fbButton.height+kButtonVerticalSpace;
    //okButton.y = vkButton.y+vkButton.height+10;
    //emailButton.y = okButton.y+okButton.height+10;
    
    [centerView addSubview:fbButton];
    [centerView addSubview:vkButton];
    //[popupView addSubview:okButton];
    //[popupView addSubview:emailButton];
    
    centerView.height = vkButton.y+vkButton.height+20;
    centerView.y = (popupView.height - centerView.height)/2;
}

-(void)fbTapped:(UIButton*)button{
    [self hide];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowHud" object:self];
    [[LoginManager sharedController] loginTo:Facebook withBlock:^(BOOL finished, NSDictionary *data) {
        if (finished) {
            [self loggedSuccess:Facebook data:data];
        }else{
            [self loggedFail:Facebook];
        }
    }];
}

-(void)vkTapped:(UIButton*)button{
    [self hide];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowHud" object:self];
    [[LoginManager sharedController] loginTo:Vkontakte withBlock:^(BOOL finished, NSDictionary *data) {
        if (finished) {
            [self loggedSuccess:Vkontakte data:data];
        }else{
            [self loggedFail:Vkontakte];
        }
    }];
}

-(void)okTapped:(UIButton*)button{
    [self hide];
    /*
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowHud" object:self];
    [[LoginManager sharedController] loginTo:@"ok" withBlock:^(BOOL success){
        if (success) {
            [self loggedSuccess:@"ok"];
        }else{
            [self loggedFail:@"ok"];
        }
    }];*/
}

-(void)emailTapped:(UIButton*)button{
    [self hide];
    //[HOLDER.root performSegueWithIdentifier:@"LoginEmail" sender:self];
}

-(void)loggedSuccess:(NSString *)network data:(NSDictionary *)data{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HideHud" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginSuccessNotification object:self userInfo:@{@"network" : network, @"data":data}];
}

-(void)loggedFail:(NSString *)network{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HideHud" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginFailNotification object:self userInfo:@{@"network" : network}];
}

@end
