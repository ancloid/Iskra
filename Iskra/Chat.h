//
//  Chat.h
//  vchat
//
//  Created by Alexey Fedotov on 22/11/2016.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Chat : NSObject

@property (nonatomic) NSString *cid;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *url;
@property (nonatomic) NSString *distance;
@property (nonatomic) NSString *age;

-(void)createWithData:(NSDictionary *)data;

@end
