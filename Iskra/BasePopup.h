//
//  BasePopup.h
//  Webka
//
//  Created by Alexey Fedotov on 04/06/15.
//  Copyright (c) 2015 Ancle Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KLCPopup.h"
#import <BFPaperButton/BFPaperButton.h>
#import "FrameAccessor.h"

typedef void (^DismissBlock)(BOOL withAction, NSString *action);

//ALWAYS DO THIS POPUP LIKE PROPERTIES IF YOU WANT TO USE CALLBACK BLOCK

@interface BasePopup : NSObject{
    UIView *root;
    KLCPopup* popup;
    UIView *popupView;
    UIView *centerView;
    UILabel *titleLabel;
    UILabel *subtitleLabel;
    UILabel *hintLabel;
}

@property (nonatomic) BOOL isShowed;
@property (nonatomic, copy) DismissBlock dismissBlock;

-(id)initWithRoot:(UIView *)value;
-(void)setTitle:(NSString *)value;
-(void)setSubTitle:(NSString *)value;
-(void)setHint:(NSString *)value;
-(void)show;
-(void)hide;
-(void)create;
-(void)setImage:(UIImage *)img forButton:()btn;
-(BFPaperButton *)setupButtonWithTitle:(NSString *)title andColor:(UIColor *)color andTextColor:(UIColor *)text_color andAction:(SEL)action;
-(BFPaperButton *)setupSmallButtonWithColor:(UIColor *)color andAction:(SEL)action;
- (void)showWithDismissBlock;
- (void)setDismissOnBackgroundTouch:(BOOL)value;

@end
