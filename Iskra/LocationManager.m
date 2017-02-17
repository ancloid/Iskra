//
//  LocationManager.m
//  vchat
//
//  Created by Alexey Fedotov on 08/12/2016.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import "LocationManager.h"
#import <INTULocationManager/INTULocationManager.h>

@interface LocationManager ()<CLLocationManagerDelegate>{
    
}

@end

@implementation LocationManager

+ (instancetype)sharedController
{
    static LocationManager *__sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedController = [[LocationManager alloc] init];
    });
    return __sharedController;
}

-(id)init{
    if((self = [super init])) {
        NSLog(@"Iska: Location Init");
        if([CLLocationManager locationServicesEnabled]){
            self.isLocationEnabled = NO;
            self.lat = [NSNumber numberWithInt:0];
            self.lon = [NSNumber numberWithInt:0];
            
            if (nil == self.locationManager){
                self.locationManager = [CLLocationManager new];
                self.locationManager.delegate = self;
            }else{
                DDLogError(@"ERROR Location services are not enabled");
            }
        }
    }
    return self;
}

- (BOOL)isAvailable{
    if(INTULocationManager.locationServicesState != INTULocationServicesStateAvailable){
        return NO;
    }else{
        return YES;
    }
}

-(void)ask{
    if([CLLocationManager locationServicesEnabled]){
        //self.locationManager = [CLLocationManager new];
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
}

-(void)getLocation{
    
    if(INTULocationManager.locationServicesState == INTULocationServicesStateAvailable){
        INTULocationManager *locMgr = [INTULocationManager sharedInstance];
        
        [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity
                                           timeout:10.0
                              delayUntilAuthorized:YES
                                             block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                                 if (status == INTULocationStatusSuccess) {
                                                     
                                                     self.isLocationEnabled = YES;
                                                     
                                                     // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                                                     // currentLocation contains the device's current location.
                                                     
                                                     DDLogInfo(@"latitude %+.6f, longitude %+.6f\n",
                                                               currentLocation.coordinate.latitude,
                                                               currentLocation.coordinate.longitude);
                                                     
                                                     self.lat = [NSNumber numberWithFloat:currentLocation.coordinate.latitude];
                                                     self.lon = [NSNumber numberWithFloat:currentLocation.coordinate.longitude];
                                                     
                                                 } else if (status == INTULocationStatusTimedOut) {
                                                     // Wasn't able to locate the user with the requested accuracy within the timeout interval.
                                                     // However, currentLocation contains the best location available (if any) as of right now,
                                                     // and achievedAccuracy has info on the accuracy/recency of the location in currentLocation.
                                                 }else {
                                                     // An error occurred, more info is available by looking at the specific status returned.
                                                 }
                                             }];
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        //if approve in intro or in settings
        [self getLocation];
    }
}

@end
