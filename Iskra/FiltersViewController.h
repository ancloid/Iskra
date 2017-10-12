//
//  FiltersViewController.h
//  Iskra
//
//  Created by Alexey Fedotov on 02/10/16.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import "TTRangeSlider.h"
#import <UIKit/UIKit.h>

@interface FiltersViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet TTRangeSlider *rangeSlider;
@property (weak, nonatomic) IBOutlet UISwitch *geoSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *menSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *womenSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *sexSwitch;

@end
