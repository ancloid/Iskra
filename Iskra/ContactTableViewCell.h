//
//  ContactTableViewCell.h
//  Iskra
//
//  Created by Alexey Fedotov on 25/11/2016.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end
