//
//  RulesViewController.m
//  vchat
//
//  Created by Alexey Fedotov on 21/11/2016.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import "RulesViewController.h"
#import "NSString+EMAdditions.h"

@interface RulesViewController ()

@end

@implementation RulesViewController

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
    titleLabel.text = @"Правила сервиса";
    [contentView addSubview:titleLabel];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(16,40,self.view.width-32,100)];
    [textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    textLabel.numberOfLines = 0;
    textLabel.font = [UIFont systemFontOfSize:14];
    NSString *ht = @"<strong>Пожалуйста, никаких сексуальных действий.</strong>\nМы строго следим, чтобы система не была использована для сексуальных действий, потому что это может выглядеть неприятно, или шокировать. В случае игнорирования этого правила мы в большинстве случаев блокируем без предупреждения доступ к сервису.\n\n<strong>Никакого обнажённого тела более того, что обычно принято.</strong>\nЕсли ваш собеседник решит, что видит намеренную демонстрацию обнажённого тема, он сможет пожаловаться. Скорее всего, мы заблокируем такой аккаунт без предупреждения.\n\n<strong>Никаких слов, которые могут обидеть или задеть собеседника.</strong>\nВедите себя так, чтобы собеседник не испытывал негативных эмоций. Позитивный настрой будет способствовать знакомству.\n\n<strong>Заинтересуйте и рассмешите собеседника.</strong>\nЕсли вы сможете подарить позитивные эмоции во время общения вашему собеседнику, они непременно вернутся к вам в удвоенном размере. Помните, самый лучший собеседник — понятный, общительный и позитивный человек.\n\n<strong>Мы проверяем автоматическими алгоритмами все трансляции, идущие в эфире.</strong>\nВ случае нарушения правил доступ к сервису блокируется навсегда.";
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
