//
//  User.h
//  Iskra
//
//  Created by Alexey Fedotov on 07/10/2016.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

@interface User : NSObject

@property (nonatomic) NSString *uid;
@property (nonatomic) NSString *name;
@property (nonatomic) NSNumber *male; //1 || 0
@property (nonatomic) NSNumber *bday;
@property (nonatomic) NSString *link;
@property (nonatomic) NSString *platform;
@property (nonatomic) BOOL inited;

-(void)createFor:(NSString *)platform withData:(NSDictionary *)data;
-(void)createWithData:(NSArray *)data; //from backend

@end
