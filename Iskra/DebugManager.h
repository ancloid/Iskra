//
//  DebugManager.h
//  vchat
//
//  Created by Alexey Fedotov on 16/02/2017.
//  Copyright © 2017 Ancle Apps. All rights reserved.
//


@interface DebugManager : NSObject

+ (DebugManager *)sharedInstance;

@property (nonatomic, strong) NSString *debugText;



- (void)addDebug:(NSString *)value;

@end
