//
//  DataManager.h
//  Iskra
//
//  Created by Alexey Fedotov on 07/10/2016.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

@class User;

@interface DataManager : NSObject

#define CACHE [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Library/Caches/Cache/"]]

+ (DataManager *)sharedController;

//user defaults
- (id)readSecureDataWithName:(NSString *)name;
- (BOOL)writeSecureData:(id)data withName:(NSString *)name;

//global cache

+ (void)saveUser:(User *)user;
+ (User *)loadUser;

+ (void)saveFilters:(NSDictionary *)data;
+ (NSDictionary *)loadFilters;

+ (void)saveRules:(BOOL)value;
+ (BOOL)loadRules;

+ (void)saveContacts:(NSArray *)data;
+ (NSArray *)loadContacts;

+ (void)saveBool:(BOOL)value withName:(NSString *)name;
+ (BOOL)loadBool:(NSString *)name;

//local cache

- (BOOL)writeData:(id)data withName:(NSString *)name;
- (id)readDataWithName:(NSString *)name;

@end
