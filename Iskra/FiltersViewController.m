//
//  FiltersViewController.m
//  Iskra
//
//  Created by Alexey Fedotov on 02/10/16.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import "DataManager.h"
#import "FiltersViewController.h"
#import <PopupDialog/PopupDialog-Swift.h>
#import <INTULocationManager/INTULocationManager.h>
#import "LocationManager.h"
#import <RESideMenu/RESideMenu.h>

@interface FiltersViewController () <TTRangeSliderDelegate>

@property (nonatomic) PopupDialog *popup;
@property float minAge;
@property float maxAge;
@property BOOL geo;
@property BOOL men;
@property BOOL women;
@property BOOL sex;
@property (nonatomic, copy) NSMutableDictionary *settings;

@end

@implementation FiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *settings = [DataManager loadFilters];
    
    if(!settings){
        settings = @{@"geo":@(LOCATION.isLocationEnabled), @"sex":@1, @"men":@1, @"women":@1, @"minAge":@18.0, @"maxAge":@60.0};
        DDLogInfo(@"Iskra: new settings %@", settings);
    }else{
        DDLogInfo(@"Iskra: old settings %@", settings);
    }
    
    self.minAge = [settings[@"minAge"] floatValue];
    self.maxAge = [settings[@"maxAge"] floatValue];
    
    if(LOCATION.isLocationEnabled){
        self.geo = [settings[@"geo"] boolValue];
    }else{
        self.geo = NO;
    }
    
    self.men = [settings[@"men"] boolValue];
    self.women = [settings[@"women"] boolValue];
    self.sex = [settings[@"sex"] boolValue];
    
    self.rangeSlider.tintColor = [UIColor grayColor];
    self.rangeSlider.handleColor = colorFromInteger(0xFFB61C);
    self.rangeSlider.tintColorBetweenHandles = colorFromInteger(0xFFB61C);
    self.rangeSlider.minValue = 18;
    self.rangeSlider.maxValue = 60;
    self.rangeSlider.selectedMinimum = self.minAge;
    self.rangeSlider.selectedMaximum = self.maxAge;
    self.rangeSlider.minDistance = 5;
    self.rangeSlider.enableStep = YES;
    self.rangeSlider.step = 1;
    self.rangeSlider.delegate = self;
    
    [self.geoSwitch setOn:self.geo];
    [self.menSwitch setOn:self.men];
    [self.womenSwitch setOn:self.women];
    [self.sexSwitch setOn:self.sex];
}

-(void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum{
    
    self.minAge = selectedMinimum;
    self.maxAge = selectedMaximum;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeTapped:(id)sender {
    NSDictionary *settings = @{@"geo":@(self.geo), @"men":@(self.men), @"women":@(self.women), @"minAge":@(self.minAge), @"maxAge":@(self.maxAge)};
    
    DDLogInfo(@"Iskra: settings %@", settings);
    
    [DataManager saveFilters:settings];
    
    [self.sideMenuViewController hideMenuViewController];
}

- (IBAction)geoChanged:(id)sender {
    
    if(self.geoSwitch.isOn){
        if(!LOCATION.isAvailable){
            //show error
            [self showSettingsError:@"Нам нужно определить вашу локацию.\nПожалуйста разрешите доступ в Настройках."];
            [self.geoSwitch setOn:NO];
        }else{
            self.geo = self.geoSwitch.isOn;
        }
    }else{
        self.geo = self.geoSwitch.isOn;
    }
}

- (IBAction)sexChanged:(id)sender {
    self.sex = self.sexSwitch.isOn;
}

- (IBAction)menChanged:(id)sender {
    //TODO: if men than ask to subscription
    
    self.men = self.menSwitch.isOn;
}

- (IBAction)womenChanged:(id)sender {
    self.women = self.womenSwitch.isOn;
}

-(void)showSettingsError:(NSString *)text{
    self.popup = [[PopupDialog alloc] initWithTitle:@"Ошибка"
                                                    message:text
                                                      image:nil
                                            buttonAlignment:UILayoutConstraintAxisHorizontal
                                            transitionStyle:PopupDialogTransitionStyleBounceUp
                                           gestureDismissal:YES
                                                 completion:nil];
    
    DefaultButton *v1 = [[DefaultButton alloc] initWithTitle:@"Настройки" height:kPopupButtonHeight dismissOnTap:YES action:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        });
    }];
    
    [self.popup addButtons: @[v1]];
    [self presentViewController:self.popup animated:YES completion:nil];
}

-(void)dismissPopup{
    [self.popup dismiss:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
}

@end
