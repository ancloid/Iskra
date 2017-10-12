//
//  Chat.m
//  Iskra
//
//  Created by Alexey Fedotov on 22/11/2016.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import "Chat.h"

@implementation Chat

-(void)createWithData:(NSDictionary *)data{
    self.cid = [data objectForKey:@"chatId"];
    self.name = [data objectForKey:@"name"];
    self.url = [data objectForKey:@"url"];
    
    int year = [[data objectForKey:@"year"] intValue];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    int nowYear = [yearString intValue];
    int age = nowYear - year;
    
    NSString *end = @"лет";
    int lastDigit = age % 10;
    if(lastDigit == 1){
        end = @"год";
    }else if (lastDigit > 1 && lastDigit < 5){
        end = @"года";
    }
    self.age = [NSString stringWithFormat:@"%i %@", age, end];
    
    int dist = [[data objectForKey:@"distance"] intValue];
    if(dist < 1){
        self.distance = @"Менее 1 км";
    }else{
        self.distance = [NSString stringWithFormat:@"%i км", dist];
    }
}

@end
