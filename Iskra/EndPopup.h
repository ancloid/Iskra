//
//  LoginPopup.h
//  Webka
//
//  Created by Alexey Fedotov on 21/08/15.
//  Copyright (c) 2015 Ancle Apps. All rights reserved.
//

#import "BasePopup.h"

@interface EndPopup : BasePopup{
    BFPaperButton *fbButton;
    BFPaperButton *vkButton;
}

-(void)showWithReason:(EndReason)reason;

@end
