//
//  StoreManager.h
//  Iskra
//
//  Created by Alexey Fedotov on 08/12/2016.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//
#import <Foundation/Foundation.h>
@class SKPaymentTransaction;

typedef void (^StoreBlock)(SKPaymentTransaction *data, NSError *error);
typedef void (^RestoreBlock)(NSArray *data, NSError *error);
typedef void (^ValidBlock)(BOOL isSubValid, BOOL needOnline);

typedef NS_ENUM(NSInteger, StoreStatus) {
    Unchecked,
    Trial,
    Subscription
};

@interface StoreManager : NSObject

+ (StoreManager *)sharedInstance;

@property (nonatomic, getter=isReceipeRefreshed) BOOL receipeRefreshed;
@property (nonatomic, getter=isProductsLoaded) BOOL productsLoaded;
@property (nonatomic, getter=isSubsriptionValid) BOOL subsriptionValid;
@property (nonatomic, getter=isSubscriptionChecked) BOOL subscriptionChecked;

@property (nonatomic) StoreStatus status;

@property (nonatomic) NSString *booksVer;

-(void)buy:(int)subId withBlock:(StoreBlock)block;
-(void)restorePurchases:(RestoreBlock)block;

-(NSString *)getPriceOfProduct:(NSString *)productIdentifier;
-(NSString *)getPriceOf:(SKPaymentTransaction *)transaction;

-(BOOL)checkSubscription;
-(void)start;
-(void)checkSubValid:(ValidBlock)block;

@end
