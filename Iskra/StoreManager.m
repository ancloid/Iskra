//
//  StoreManager.m
//  KidBookGold
//
//  Created by Alexey Fedotov on 24/07/16.
//  Copyright © 2016 Blue MArlin Technologies Corp. All rights reserved.
//

//#import "Amplitude.h"
#import "StoreManager.h"
#import "RMStore.h"
#import "RMStoreKeychainPersistence.h"
#import "RMStoreUserDefaultsPersistence.h"
#import "RMAppReceipt.h"
#import "Reachability.h"
#import "DebugManager.h"
#import "DataManager.h"

#define PRODUCTS_ARRAY (@[@"autosub.week.iskra"])

@implementation StoreManager

+ (StoreManager *)sharedInstance {
    static StoreManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[StoreManager alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.productsLoaded = false;
        self.subscriptionChecked = false;
        self.subsriptionValid = false;
        self.status = Unchecked;
        self.receipeRefreshed = false;
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)start{
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [reach startNotifier];
}

//TODO: make one reachebiliyty
-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if([reach isReachable])
    {
        NSLog(@"Internet is Up %i", [RMStore canMakePayments]);
        
        if([RMStore canMakePayments]){
            
            if(!self.isProductsLoaded){
                [self getProducts];
            }
            
            if(!self.isSubscriptionChecked){
                //if user did purchase or restored product, then receipt will exists, so check it
                if([self isReceiptExists])
                {
                    [self checkSubscription];
                    
                }else{
                    NSLog(@"No receipt found");
                }
            }
        }else{
            NSLog(@"I can't make payments!");
        }
    }
    else
    {
        NSLog(@"Internet is Down");
        
    }
}

-(void)getProducts{
    NSLog(@"getProducts");
    
    self.productsLoaded = true;
    
    NSSet *products = [NSSet setWithArray:PRODUCTS_ARRAY];
    [[RMStore defaultStore] requestProducts:products success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        NSLog(@"Products loaded %@", products);
        
        for (SKProduct *product in products) {
            NSLog(@"Product: %@ %@ %@", product.productIdentifier, product.price, product.priceLocale.localeIdentifier);
        }
        
        self.productsLoaded = true;
        
    } failure:^(NSError *error) {
        NSLog(@"Something went wrong");
        
        self.productsLoaded = false;
    }];
}

-(NSString *)getPriceOfProduct:(NSString *)productIdentifier{
    SKProduct *product = [[RMStore defaultStore] productForIdentifier:productIdentifier];
    NSNumber *productPrice = product.price;
    return [productPrice stringValue];
}

-(NSString *)getPriceOf:(SKPaymentTransaction *)transaction{
    return [self getPriceOfProduct:transaction.payment.productIdentifier];
}



//wont ask password, can call from reachability or from refresh receipt or from checking
-(BOOL)checkSubscription{
    
    self.subsriptionValid = false;
    self.subscriptionChecked = true;
        
    RMAppReceipt* appReceipt = [RMAppReceipt bundleReceipt];
    
    //for test and log
    for (int i = 0; i < appReceipt.inAppPurchases.count; i++) {
        RMAppReceiptIAP *iap = appReceipt.inAppPurchases[i];
        if(i == appReceipt.inAppPurchases.count-1){
            
            [[DebugManager sharedInstance] addDebug:[NSString stringWithFormat:@"STORE last iap = %@ date:%@ ex:%@", iap.productIdentifier, iap.purchaseDate, iap.subscriptionExpirationDate]];
        }
    }
    
    for (int j = 0; j < PRODUCTS_ARRAY.count; j++){
        
        //sub can be trial or not trial, it's just valid
        if([appReceipt containsActiveAutoRenewableSubscriptionOfProductIdentifier:PRODUCTS_ARRAY[j] forDate:[NSDate date]]){
            self.subsriptionValid = true;
            self.status = Trial;
            
            [[DebugManager sharedInstance] addDebug:@"Subscription found"];
        }
        
        //check all subscription, if someone valid, than this is not a first time, so this is not a TRIAL
        if([appReceipt containsInAppPurchaseOfProductIdentifier:PRODUCTS_ARRAY[j]]){
            self.status = Subscription;
            [[DebugManager sharedInstance] addDebug:@"Subscription live"];
        }else{
            [[DebugManager sharedInstance] addDebug:@"Subscription trial"];
        }
    }
    
    [[DebugManager sharedInstance] addDebug:[NSString stringWithFormat:@"STORE subsriptionValid = %i status = %li", self.isSubsriptionValid, (long)self.status]];
    self.subscriptionChecked = true;
    
    //save exp date
    if(self.isSubsriptionValid){
        RMAppReceiptIAP *iap = [self getLastValidSubscription];
        
        NSDate *savedDate = [DATA readSecureDataWithName:@"expSubDate"];
        
        [[DebugManager sharedInstance] addDebug:[NSString stringWithFormat:@"STORE expSubDate = %@", savedDate]];
        
        if(savedDate == nil || [iap.subscriptionExpirationDate compare:savedDate] != NSOrderedSame){
            [DATA writeSecureData:iap.subscriptionExpirationDate withName:@"expSubDate"];
            [[DebugManager sharedInstance] addDebug:[NSString stringWithFormat:@"STORE save exp date = %@", iap.subscriptionExpirationDate]];
        }
    }
    
    return self.subsriptionValid;
}

-(RMAppReceiptIAP *)getLastValidSubscription{
    RMAppReceipt* appReceipt = [RMAppReceipt bundleReceipt];
    RMAppReceiptIAP *lastTransaction = nil;
    
    for (RMAppReceiptIAP *iap in appReceipt.inAppPurchases)
    {
        if (!lastTransaction || [iap.subscriptionExpirationDate compare:lastTransaction.subscriptionExpirationDate] == NSOrderedDescending)
        {
            lastTransaction = iap;
        }
    }
    
    return lastTransaction;
}


-(void)buy:(int)subId withBlock:(StoreBlock)block{
    [self buyProduct:PRODUCTS_ARRAY[subId] withBlock:block];
}

-(void)buyProduct:(NSString *)productId withBlock:(StoreBlock)block{
    [[RMStore defaultStore] addPayment:productId success:^(SKPaymentTransaction *transaction) {
        NSLog(@"Product purchased");
        
        [[[RMStore defaultStore] receiptVerificator] verifyTransaction:transaction success:^{
            NSLog(@"verifyTransaction OK");
            
            if (block != nil) {
                block(transaction, nil);
            }
        } failure:^(NSError *error) {
            NSLog(@"verifyTransaction ERROR %@", error.description);
            if (block != nil) {
                block(nil, error);
            }
        }];
        
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        NSLog(@"Something went wrong %@", error.description);
        if (block != nil) {
            block(nil, error);
        }
    }];
}

-(void)restorePurchases:(RestoreBlock)block{
    [[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions){
        NSLog(@"Transactions restored");
        if (block != nil) {
            block(transactions, nil);
        }
    } failure:^(NSError *error) {
        NSLog(@"Something went wrong  %@", error.description);
        if (block != nil) {
            block(nil, error);
        }
    }];
}

//can ask password
-(void)checkSubValid:(ValidBlock)block{
    
    if(!self.subscriptionChecked){
        [self checkSubscription];
    }
    
    //if receipt found
    if([self isReceiptExists]){
        [[DebugManager sharedInstance] addDebug:[NSString stringWithFormat:@"STORE receipt found"]];
        
        //if valid do nothing
        if(self.subsriptionValid){
            [[DebugManager sharedInstance] addDebug:[NSString stringWithFormat:@"STORE return valid"]];
            
            if (block != nil) {
                block(YES, NO);
            }
        }else{
            //if not valid, try to refresh if expired
            
            NSDate *savedDate = [DATA readSecureDataWithName:@"expSubDate"];
            [[DebugManager sharedInstance] addDebug:[NSString stringWithFormat:@"STORE savedDate %@", savedDate]];
            
            if(savedDate == nil || [[NSDate new] compare:savedDate] == NSOrderedDescending){ //if now date > stored date
                [[DebugManager sharedInstance] addDebug:[NSString stringWithFormat:@"STORE receipt expired, refresh"]];
                [self refreshReceipe:block];
            }else{
                [[DebugManager sharedInstance] addDebug:[NSString stringWithFormat:@"STORE return invalid"]];
                
                //receipt refreshed and sub is INVALID
                if (block != nil) {
                    block(NO, NO);
                }
            }
        }
    }else{
        [[DebugManager sharedInstance] addDebug:[NSString stringWithFormat:@"STORE no receipt found, refresh"]];
        //no receipt found
        [self refreshReceipe:block];
    }
}

//will ask password
-(void)refreshReceipe:(ValidBlock)block{
    
    [[RMStore defaultStore] refreshReceiptOnSuccess:^{
        NSLog(@"Receipt refreshed");
        self.receipeRefreshed = true;
        if (block != nil) {
            block([self checkSubscription], NO);
        }
    }failure:^(NSError *error) {
        self.receipeRefreshed = false;
        NSLog(@"RMStore Something went wrong: %@", error.description);
        if (block != nil) {
            block(NO, YES);
        }
        
    }];
}

-(BOOL)isReceiptExists{
    return [[NSFileManager defaultManager] fileExistsAtPath:[[[NSBundle mainBundle] appStoreReceiptURL] path]];
}

@end
