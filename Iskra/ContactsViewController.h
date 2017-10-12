//
//  ContactsViewController.h
//  Iskra
//
//  Created by Alexey Fedotov on 21/11/2016.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;

@end
