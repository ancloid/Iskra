//
//  RegisterViewController.h
//  vchat
//
//  Created by Alexey Fedotov on 22/11/2016.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface RegisterViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *nameButton;
@property (weak, nonatomic) IBOutlet UIButton *sexButton;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *sexPicker;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbarView;

-(void)initUser:(User *)user;

@end
