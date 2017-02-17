//
//  LoginPopup.m
//  Webka
//
//  Created by Alexey Fedotov on 21/08/15.
//  Copyright (c) 2015 Ancle Apps. All rights reserved.
//

#import "EndPopup.h"
#import "NSString+EMAdditions.h"
#import "LoginManager.h"

#define kTitleToButtonVerticalSpace 50
#define kButtonVerticalSpace 15

@implementation EndPopup

-(void)create{
    [super create];
    
    [self setTitle:NSLocalizedString(@"endPopupTitle", nil)];
    [self setSubTitle:NSLocalizedString(@"endPopupSubTitle", nil)];
    [self setHint:NSLocalizedString(@"hintAddTitle", nil)];
    
    fbButton = [self setupButtonWithTitle:NSLocalizedString(@"continueButtonLabel", nil) andColor:colorFromInteger(0x24BF5F) andTextColor:[UIColor whiteColor] andAction:@selector(yesTapped:)];
    vkButton = [self setupButtonWithTitle:NSLocalizedString(@"cancelButtonLabel", nil) andColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.2] andTextColor:[UIColor whiteColor] andAction:@selector(noTapped:)];

    fbButton.y = subtitleLabel.y+subtitleLabel.height+kTitleToButtonVerticalSpace;
    vkButton.y = fbButton.y+fbButton.height+kButtonVerticalSpace;
    
    [centerView addSubview:fbButton];
    [centerView addSubview:vkButton];
    
    centerView.height = vkButton.y+vkButton.height+20;
    centerView.y = (popupView.height - centerView.height)/2;
}

-(void)showWithReason:(EndReason)reason{
    switch (reason) {
        case TimeOut:
            [self setTitle:NSLocalizedString(@"endTimeOutPopupTitle", nil)];
            break;
        case ConnectionError:
            [self setTitle:NSLocalizedString(@"endConnectionErrorPopupTitle", nil)];
            break;
        case InterruptedByMe:
            [self setTitle:NSLocalizedString(@"endInterruptedByMePopupTitle", nil)];
            break;
        case InterruptedByOpponent:
            [self setTitle:NSLocalizedString(@"endInterruptedByOpponentPopupTitle", nil)];
            break;
        default:
            [self setTitle:NSLocalizedString(@"endPopupTitle", nil)];
            break;
    }
    
    [self show];
}

-(void)yesTapped:(UIButton*)button{
    [self hide];
    [[NSNotificationCenter defaultCenter] postNotificationName:YesEndNotification object:self userInfo:nil];
}

-(void)noTapped:(UIButton*)button{
    [self hide];
    [[NSNotificationCenter defaultCenter] postNotificationName:NoEndNotification object:self userInfo:nil];
}

@end
