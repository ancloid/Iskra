//
//  ApiManager.h
//  Iskra
//
//  Created by Alexey Fedotov on 07/10/2016.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

@import SocketIO;

typedef NS_ENUM(NSInteger, ApiStatus) {
    ApiConnected,
    ApiDisconnected,
    ApiError,
    ApiReconnect
};

@interface ApiManager : NSObject

@property (nonatomic) SocketIOClient* socket;
@property (nonatomic) ApiStatus apiStatus;

+ (instancetype)sharedController;
-(void)callMethod:(NSString *)method withData:(NSDictionary *)data;

@end
