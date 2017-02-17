//
//  LocationManager.h
//  vchat
//
//  Created by Alexey Fedotov on 08/12/2016.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@interface LocationManager : NSObject

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSNumber *lon;
@property (nonatomic) NSNumber *lat;
@property (nonatomic) BOOL isLocationEnabled;

+ (instancetype)sharedController;
- (void)ask;
- (BOOL)isAvailable;

@end
