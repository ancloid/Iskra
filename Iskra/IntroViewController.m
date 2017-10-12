//
//  IntroViewController.m
//  Iskra
//
//  Created by Alexey Fedotov on 09/11/2016.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import "IntroViewController.h"
#import <BFPaperButton/BFPaperButton.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationManager.h"

@interface IntroViewController ()

@property (nonatomic) UIView *p1view;
@property (nonatomic) UIView *p2view;

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.p1view = [[UIView alloc] initWithFrame:self.view.frame];
    self.p1view.backgroundColor = colorFromInteger(0xF2F2F2);
    
    UIImage *p1Image = [UIImage imageNamed:@"intro0"];
    UIImageView *p1ImageView = [[UIImageView alloc] initWithImage:p1Image];
    [p1ImageView setFrame:CGRectMake((self.view.bounds.size.width - p1ImageView.bounds.size.width)/2, 30, p1ImageView.bounds.size.width, p1ImageView.bounds.size.height)];
    [self.p1view addSubview:p1ImageView];
    
    BFPaperButton *btn = [[BFPaperButton alloc] initWithFrame:CGRectMake(0, self.p1view.frame.size.height - 50, self.view.bounds.size.width, 50)];
    [btn setBackgroundColor:colorFromInteger(0xFFB61C)];
    [btn setTitle:@"Включить определение гео" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onGeo:) forControlEvents:UIControlEventTouchUpInside];
    [self.p1view addSubview:btn];
    
    UILabel *p1Label = [[UILabel alloc] initWithFrame:CGRectMake(0, btn.frame.origin.y-150, self.view.bounds.size.width, 150)];
    [p1Label setBackgroundColor:[UIColor whiteColor]];
    [p1Label setTextColor:[UIColor blackColor]];
    [p1Label setFont:[UIFont systemFontOfSize:14]];
    [p1Label setLineBreakMode:NSLineBreakByWordWrapping];
    [p1Label setNumberOfLines:0];
    [p1Label setTextAlignment:NSTextAlignmentCenter];
    [p1Label setText:@"Мы автоматически подберём вам\nлучшего собеседника, который\nнаходится поблизости.\n\nКаждый видео чат\nдлится 3 минуты."];
    [self.p1view addSubview:p1Label];
    
    self.p2view = [[UIView alloc] initWithFrame:self.view.frame];
    self.p2view.backgroundColor = colorFromInteger(0xF2F2F2);
    
    UIImage *p2Image = [UIImage imageNamed:@"intro1"];
    UIImageView *p2ImageView = [[UIImageView alloc] initWithImage:p2Image];
    [p2ImageView setFrame:CGRectMake((self.view.bounds.size.width - p2ImageView.bounds.size.width)/2, 30, p2ImageView.bounds.size.width, p2ImageView.bounds.size.height)];
    [self.p2view addSubview:p2ImageView];
    
    BFPaperButton *btn2 = [[BFPaperButton alloc] initWithFrame:CGRectMake(0, self.p1view.frame.size.height - 50, self.view.bounds.size.width, 50)];
    [btn2 setBackgroundColor:colorFromInteger(0xFFB61C)];
    [btn2 setTitle:@"Разрешить уведомления" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(onPushes:) forControlEvents:UIControlEventTouchUpInside];
    [self.p2view addSubview:btn2];
    
    UILabel *p2Label = [[UILabel alloc] initWithFrame:CGRectMake(0, btn.frame.origin.y-150, self.view.bounds.size.width, 150)];
    [p2Label setBackgroundColor:[UIColor whiteColor]];
    [p2Label setTextColor:[UIColor blackColor]];
    [p2Label setLineBreakMode:NSLineBreakByWordWrapping];
    [p2Label setNumberOfLines:0];
    [p2Label setTextAlignment:NSTextAlignmentCenter];
    [p2Label setFont:[UIFont systemFontOfSize:14]];
    [p2Label setText:@"После разговора вы можете решить,\nпродолжать общение с этим человеком\n или нет.\n\nМы сообщим, если кто-то другой\nдобавит вас в контакты."];
    [self.p2view addSubview:p2Label];
    
    [self.view addSubview:self.p2view];
    [self.view addSubview:self.p1view];
    self.p2view.hidden = YES;
}

-(void)onGeo:(id)sender {
    self.p1view.hidden = YES;
    self.p2view.hidden = NO;
    
    [LOCATION ask];
}

-(void)onPushes:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
