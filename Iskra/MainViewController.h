//
//  MainViewController.h
//  Iskra
//
//  Created by Alexey Fedotov on 19/08/16.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

/*
 this fix applied
 http://stackoverflow.com/questions/31398961/exc-bad-access-at-lauch-for-eaglcontext-renderbufferstorage-fromdrawable-in-co
 */

#import <BFPaperButton/BFPaperButton.h>

@interface MainViewController : UIViewController

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *effectsCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarCons;

@property (weak, nonatomic) IBOutlet UIImageView *bigCameraImageView;
@property (weak, nonatomic) IBOutlet UIImageView *smallCameraImageView;

@property (weak, nonatomic) IBOutlet UIImageView *shotView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *smallView;

//bottom bar
@property (weak, nonatomic) IBOutlet UIView *bottomBarView;
@property (weak, nonatomic) IBOutlet BFPaperButton *effectsButton;
@property (weak, nonatomic) IBOutlet BFPaperButton *cameraButton;
@property (weak, nonatomic) IBOutlet BFPaperButton *startButton;

//effects view
@property (weak, nonatomic) IBOutlet UIView *effectsView;
@property (weak, nonatomic) IBOutlet UIButton *masksButton;
@property (weak, nonatomic) IBOutlet UIButton *filtersButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

//upper bar
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (weak, nonatomic) IBOutlet UILabel *onlineLabel;
@property (weak, nonatomic) IBOutlet UIView *mainUpperBar;
@property (weak, nonatomic) IBOutlet UILabel *chatTimerLabel;
@property (weak, nonatomic) IBOutlet UIView *chatUpperBar;

@property (weak, nonatomic) IBOutlet UILabel *chatUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *chatDistanceLabel;

@property (weak, nonatomic) IBOutlet SKView *skView;

@property (weak, nonatomic) IBOutlet UIView *connectingView;
@property (weak, nonatomic) IBOutlet UILabel *connectingLabel;

//timer
@property (weak, nonatomic) IBOutlet UIView *timerView;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerTitleLabel;



@end
