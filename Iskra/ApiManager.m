//
//  ApiManager.m
//  Iskra
//
//  Created by Alexey Fedotov on 07/10/2016.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import "ApiManager.h"

@implementation ApiManager

+ (instancetype)sharedController
{
    static ApiManager *__sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedController = [[ApiManager alloc] init];
    });
    return __sharedController;
}

-(id)init{
    if((self = [super init])) {
        NSLog(@"API INIT");
        
        self.socket = [[SocketIOClient alloc] initWithSocketURL:[[NSURL alloc] initWithString:@"http://138.201.191.91:6680"] config:@{@"log": @YES, @"forcePolling": @YES}];
        
        self.socket.reconnectWait = 1;
        [self initEvents];
    }
    return self;
}

-(void)initEvents{
    [self.socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket connected");
        self.apiStatus = ApiConnected;
    }];
    [self.socket on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket disconnected");
        self.apiStatus = ApiDisconnected;
    }];
    [self.socket on:@"error" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket error");
        self.apiStatus = ApiError;
    }];
    [self.socket on:@"reconnect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket reconnect");
    }];
    [self.socket on:@"reconnectAttempt" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket reconnectAttempt");
        self.apiStatus = ApiReconnect;
    }];

}

-(void)callMethod:(NSString *)method withData:(NSDictionary *)data{
    if(data){
        [self.socket emit:method with:@[data]];
    }else{
        [self.socket emit:method with:@[]];
    }
    
}


@end
