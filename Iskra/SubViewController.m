//
//  SubViewController.m
//  Iskra
//
//  Created by Alexey Fedotov on 08/12/2016.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import "SubViewController.h"
#import "NSString+EMAdditions.h"

@interface SubViewController ()

@end

@implementation SubViewController

- (IBAction)closeTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *contentView;
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.width,1000)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16,0,self.view.width-32,20)];
    titleLabel.numberOfLines = 1;
    titleLabel.font = [UIFont systemFontOfSize:19 weight:UIFontWeightMedium];
    titleLabel.text = @"Отключить подписку";
    [contentView addSubview:titleLabel];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(16,40,self.view.width-32,100)];
    [textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    textLabel.numberOfLines = 0;
    textLabel.font = [UIFont systemFontOfSize:14];
    
     NSString *ht = @"1. Зайдите в «Настройки» на экране «Домой» на телефоне или планшете (основной экран).\n\n2. Выберите пункт «iTunes Store и App Store».\n\n3.Нажмите свой идентификатор Apple ID в верхней части экрана.\n\n4. Выберите пункт «Просмотреть Apple ID» (Возможно, надо будет войти в систему).\n\n5. В разделе «Подписки» нажмите «Управлять».\n\n6. В этом разделе выберите ту подписку, которую хотите отключить и выключите её.\n\nНапоминаем, что изменить условия подписки можно не позже, чем за день до нового периода. То есть текущие бесплатные 7 дней пробного периода надо выключить до окончания последнего дня.\nПодробнее на официальной странице\nhttps://support.apple.com/ru-ru/HT202039";
    
    textLabel.attributedText = ht.attributedString;
    [textLabel sizeToFit];
    textLabel.width = self.view.width-32;
    [contentView addSubview:textLabel];
    
    [self.scrollView addSubview:contentView];
    [self.scrollView setContentSize:CGSizeMake(self.view.width,textLabel.height+textLabel.y+20)];
    [self.scrollView setScrollEnabled:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
