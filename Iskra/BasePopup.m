//
//  BasePopup.m
//  Webka
//
//  Created by Alexey Fedotov on 04/06/15.
//  Copyright (c) 2015 Ancle Apps. All rights reserved.
//

#import "BasePopup.h"


#define kButtonCorner 25
#define kButtonTextSize 16
#define kButtonHeight 50
#define kButtonWidth 270
#define kPopupWidth 320

#define kTitleToSubtitleVerticalSpace 17

@implementation BasePopup

-(id)initWithRoot:(UIView *)value{
    if((self = [super init])) {
        root = value;
        [self create];
    }
    return self;
}

-(void)create{
    
    self.isShowed = false;
    popupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, root.width, root.height)];
    centerView = [[UIView alloc] initWithFrame:CGRectMake((root.width - kPopupWidth)/2, 0, kPopupWidth, root.height)];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, kPopupWidth, 25)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.numberOfLines = 0;
    titleLabel.font = [UIFont systemFontOfSize:19];
    
    subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, kPopupWidth, 25)];
    subtitleLabel.backgroundColor = [UIColor clearColor];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.textColor = [UIColor whiteColor];
    subtitleLabel.numberOfLines = 0;
    subtitleLabel.font = [UIFont systemFontOfSize:16];
    
    hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kPopupWidth, 25)];
    hintLabel.backgroundColor = [UIColor clearColor];
    hintLabel.textAlignment = NSTextAlignmentCenter;
    hintLabel.textColor = [UIColor whiteColor];
    hintLabel.numberOfLines = 0;
    hintLabel.font = [UIFont systemFontOfSize:12];
    
    [centerView addSubview:titleLabel];
    [centerView addSubview:subtitleLabel];
    [popupView addSubview:hintLabel];
    [popupView addSubview:centerView];
    
    popup = [KLCPopup popupWithContentView:popupView
                                  showType:KLCPopupShowTypeShrinkIn
                               dismissType:KLCPopupDismissTypeFadeOut
                                  maskType:KLCPopupMaskTypeDimmed
                  dismissOnBackgroundTouch:true
                     dismissOnContentTouch:false];
}

-(void)show{
    if(root){
        [KLCPopup dismissAllPopups];
        [popup showWithRoot:root];
        self.isShowed = true;
    }else{
        NSLog(@"Error!, init this popup first");
    }
}

-(void)hide{
    self.isShowed = false;
    [popup dismissPresentingPopup];
}

-(void)setDismissOnBackgroundTouch:(BOOL)value{
    popup.shouldDismissOnBackgroundTouch = value;
}

-(void)showWithDismissBlock{
    __weak BasePopup *weakSelf = self;
    popup.didFinishDismissingCompletion = ^(void){
        if (weakSelf.dismissBlock){
            weakSelf.dismissBlock(false, nil);
        }else{
            //no block found
        }
    };
    
    [self show];
}

-(void)setTitle:(NSString *)value{
    titleLabel.text = value;
    [titleLabel sizeToFit];
    titleLabel.width = centerView.width;
    
    subtitleLabel.y = titleLabel.y+titleLabel.height+kTitleToSubtitleVerticalSpace;
}

-(void)setSubTitle:(NSString *)value{
    subtitleLabel.text = value;
    [subtitleLabel sizeToFit];
    subtitleLabel.width = centerView.width;
}

-(void)setHint:(NSString *)value{
    hintLabel.text = value;
    [hintLabel sizeToFit];
    hintLabel.width = popupView.width;
    hintLabel.y = popupView.height - hintLabel.height - 20;
}

-(void)setImage:(UIImage *)img forButton:()btn{
    [btn setImage:img forState:UIControlStateNormal];
    [btn setImage:img forState:UIControlStateHighlighted];
}

//TODO: add isets and align and text size and raised
-(BFPaperButton *)setupButtonWithTitle:(NSString *)title andColor:(UIColor *)color andTextColor:(UIColor *)text_color andAction:(SEL)action{
    
    BFPaperButton *button = [[BFPaperButton alloc] initWithFrame:CGRectMake((kPopupWidth-kButtonWidth)/2, 0, kButtonWidth, kButtonHeight) raised:NO];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:text_color forState:UIControlStateNormal];
    [button setTitleColor:text_color forState:UIControlStateHighlighted];
    [button setTitleColor:color forState:UIControlStateDisabled]; // [UIColor colorWithColor:text_color andAlpha:.5]
    [button setTitleFont:[UIFont systemFontOfSize:kButtonTextSize]];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    button.backgroundColor = color;
    button.cornerRadius = kButtonCorner;
    
    //[button setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)];
    //[button setContentEdgeInsets:UIEdgeInsetsMake(0.0, 25.0, 0.0, 0.0)];
    
    return button;
}

-(BFPaperButton *)setupSmallButtonWithColor:(UIColor *)color andAction:(SEL)action{
    
    BFPaperButton *button = [[BFPaperButton alloc] initWithFrame:CGRectMake(0, 0, kButtonHeight, kButtonHeight) raised:YES];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = color;
    button.cornerRadius = kButtonCorner;
    
    return button;
}

@end
