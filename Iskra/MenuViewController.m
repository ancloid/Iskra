//
//  MenuViewController.m
//  vchat
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
    // Dispose of any resources that can be recreated.
}
- (IBAction)closeTapped:(id)sender {
    //[self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"mainViewController"]] animated:YES];
    [self.sideMenuViewController hideMenuViewController];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)contactsTapped:(id)sender {
    [self performSegueWithIdentifier:@"ShowContacts" sender:self];
}

- (IBAction)subscribtionTapped:(id)sender {
    [self performSegueWithIdentifier:@"ShowSub" sender:self];
    //[self performSegueWithIdentifier:@"ShowRules" sender:self];
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions"]];
}

- (IBAction)rulesTapped:(id)sender {
    [self performSegueWithIdentifier:@"ShowRules" sender:self];
}

@end
