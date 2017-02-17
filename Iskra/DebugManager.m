//
//  DebugManager.m
//  vchat
//
//  Created by Alexey Fedotov on 16/02/2017.
//  Copyright © 2017 Ancle Apps. All rights reserved.
//

#import "DebugManager.h"

@implementation DebugManager

+ (DebugManager *)sharedInstance {
    static DebugManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DebugManager alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.debugText = @"Start debug log";
    }
    return self;
}

-(void)addDebug:(NSString *)value{
    //FIRCrashNSLog(@"%@", value);
    self.debugText = [NSString stringWithFormat:@"%@\n%@",value,self.debugText];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"debugNotification" object:nil userInfo:@{@"text":value}];
}

@end
