//
//  DataManager.m
//  vchat
//
//  Created by Alexey Fedotov on 07/10/2016.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import "DataManager.h"
#import "User.h"

@implementation DataManager

- (id)init {
    self = [super init];
    if (self) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:CACHE]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:CACHE withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

+ (DataManager *)sharedController {
    static DataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DataManager alloc] init];
    });
    return sharedInstance;
}

//user defaults data

- (id)readSecureDataWithName:(NSString *)name{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *data = [defaults objectForKey:name];
    if(data){
        return data;
    }else{
        return nil;
    }
}
- (BOOL)writeSecureData:(id)data withName:(NSString *)name{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:name];
    return [defaults synchronize];
}


+ (void)saveUser:(User *)user {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:user];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:@"iskraUser"];
    [defaults synchronize];
}

+ (User *)loadUser {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:@"iskraUser"];
    User *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}

+ (void)saveFilters:(NSDictionary *)data {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:data];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:@"iskraFilters"];
    [defaults synchronize];
}

+ (NSDictionary *)loadFilters{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:@"iskraFilters"];
    NSDictionary *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}

+ (void)saveBool:(BOOL)value withName:(NSString *)name{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:[NSNumber numberWithBool:value]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:name];
    [defaults synchronize];
}

+ (BOOL)loadBool:(NSString *)name{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:name];
    BOOL object = [[NSKeyedUnarchiver unarchiveObjectWithData:encodedObject] boolValue];
    return object;
}

+ (void)saveRules:(BOOL)value{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:[NSNumber numberWithBool:value]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:@"iskraRules"];
    [defaults synchronize];
}

+ (BOOL)loadRules{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:@"iskraRules"];
    BOOL object = [[NSKeyedUnarchiver unarchiveObjectWithData:encodedObject] boolValue];
    return object;
}

+ (void)saveContacts:(NSArray *)data {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:data];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:@"iskraContacts"];
    [defaults synchronize];
}

+ (NSArray *)loadContacts{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:@"iskraContacts"];
    NSArray *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}

//local cache (deleted after reinstall)

- (BOOL)writeData:(id)data withName:(NSString *)name{
    NSString *path = [NSString stringWithFormat:@"%@%@", CACHE, name];
    NSData *dataArch = [NSKeyedArchiver archivedDataWithRootObject:data];
    NSError *errorWriting;
    [dataArch writeToFile:path options:NSDataWritingAtomic error:&errorWriting];
    if(errorWriting != nil){
        return NO;
    }else{
        return YES;
    }
}

- (id)readDataWithName:(NSString *)name {
    NSString *path = [NSString stringWithFormat:@"%@%@", CACHE, name];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (fileExists) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        id result = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return result;
    } else {
        return nil;
    }
}

@end
