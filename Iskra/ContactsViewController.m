//
//  ContactsViewController.m
//  vchat
//
//  Created by Alexey Fedotov on 21/11/2016.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import "ContactTableViewCell.h"
#import "ContactsViewController.h"
#import "DataManager.h"
#import "User.h"

@interface ContactsViewController () <UITableViewDelegate, UITableViewDataSource>{
    //NSArray *contactsArray;
}

@property (nonatomic, copy) NSMutableArray *contactsArray;

@end

@implementation ContactsViewController

- (IBAction)closeTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new]; //remove empty separators
    
    self.contactsArray = [NSMutableArray new];
    
    NSArray *contacts = [DataManager loadContacts];
    if(contacts){
        self.contactsArray = [self parseContacts:contacts];
    }
    
    if(self.contactsArray.count > 0){
        self.emptyView.hidden = YES;
        self.tableView.hidden = NO;
    }else{
        self.emptyView.hidden = NO;
        self.tableView.hidden = YES;
    }
}

- (NSMutableArray *)parseContacts:(NSArray *)data{
    NSMutableArray *array = [NSMutableArray new];
    
    for (NSArray *userData in data) {
        if(userData.count > 0){
            for (int i = 0; i < userData.count; i++) {
                User *user = [User new];
                [user createWithData:[userData objectAtIndex:i]];
                [array addObject:user];
            }
            
            
        }
    }
    
    return [array mutableCopy];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contactsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    User *user = [self.contactsArray objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = user.name;
    cell.subtitleLabel.text = user.link;
    cell.iconImageView.image = [UIImage imageNamed:@"ic_filter"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [self.contactsArray objectAtIndex:indexPath.row];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:user.link]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
