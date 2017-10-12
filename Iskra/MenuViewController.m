//
//  MenuViewController.m
//  Iskra
//
//  Created by Alexey Fedotov on 02/10/16.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import <PopupDialog/PopupDialog-Swift.h>
#import "MenuViewController.h"
#import <RESideMenu/RESideMenu.h>

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)closeTapped:(id)sender {
    [self.sideMenuViewController hideMenuViewController];
}

- (IBAction)contactsTapped:(id)sender {
    [self performSegueWithIdentifier:@"ShowContacts" sender:self];
}

- (IBAction)subscribtionTapped:(id)sender {
    [self performSegueWithIdentifier:@"ShowSub" sender:self];
}

- (IBAction)rulesTapped:(id)sender {
    [self performSegueWithIdentifier:@"ShowRules" sender:self];
}

@end
