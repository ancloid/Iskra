//
//  RegisterViewController.m
//  Iskra
//
//  Created by Alexey Fedotov on 22/11/2016.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic) User *user;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.doneButton.hidden = YES;
    self.datePicker.hidden = YES;
    self.sexPicker.hidden = YES;
    self.toolbarView.hidden = YES;
    
    [self.datePicker addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.sexPicker.delegate = self;
    self.sexPicker.dataSource = self;
    
    //toolbar
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneClicked)];
    [doneBtn setTintColor:colorFromInteger(0xFFB61C)];
    [barItems addObject:doneBtn];
    [self.toolbarView setItems:barItems animated:YES];
    
    if(self.user){
        [self.nameButton setTitle:self.user.name forState:UIControlStateNormal];
        
        if(self.user.bday){
            [self.dateButton setTitle:[NSString stringWithFormat:@"%@%@", @"Год рождения: ", self.user.bday] forState:UIControlStateNormal];
        }else{
            [self.dateButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        
        if(self.user.male){
            if([self.user.male intValue] == 0){
                [self.sexButton setTitle:@"Пол: женский" forState:UIControlStateNormal];
            }else if([self.user.male intValue] == 1){
                [self.sexButton setTitle:@"Пол: мужской" forState:UIControlStateNormal];
            }
        }else{
            [self.sexButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
    }
}

- (void)initUser:(User *)user{
    self.user = user;

}

-(void)pickerDoneClicked
{
    self.datePicker.hidden = YES;
    self.sexPicker.hidden = YES;
    self.toolbarView.hidden = YES;
    
    [self checkAllFields];
}

//SEX

- (IBAction)sexTapped:(id)sender {
    self.sexPicker.hidden = NO;
    self.toolbarView.hidden = NO;
    self.doneButton.hidden = YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 2;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(row == 0){
        return @"Женский";
    }else{
        return @"Мужской";
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    self.user.male = [NSNumber numberWithInteger:row];
    if(row == 0){
        [self.sexButton setTitle:@"Пол: женский" forState:UIControlStateNormal];
    }else{
        [self.sexButton setTitle:@"Пол: мужской" forState:UIControlStateNormal];
    }
    [self.sexButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    
    
}

//DATE

- (IBAction)dateTapped:(id)sender {
    self.datePicker.hidden = NO;
    self.toolbarView.hidden = NO;
    self.doneButton.hidden = YES;
}

- (void)onDatePickerValueChanged:(UIDatePicker *)datePicker
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:datePicker.date];
    NSInteger year = [components year];
    
    self.user.bday = [NSNumber numberWithInteger:year];
    [self.dateButton setTitle:[NSString stringWithFormat:@"%@%@",@"Год рождения: ",self.user.bday] forState:UIControlStateNormal];
    [self.dateButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
}

-(void)checkAllFields{
    if(self.user.bday != nil && self.user.male != nil){
        self.doneButton.hidden = NO;
    }
}

- (IBAction)doneTapped:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:UserCompleteNotification object:self userInfo:@{@"user":self.user}];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
