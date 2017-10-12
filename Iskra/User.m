//
//  User.m
//  Iskra
//
//  Created by Alexey Fedotov on 07/10/2016.
//  Copyright © 2016 Ancle Apps. All rights reserved.
//

#import "User.h"
#import "Utils.h"

@implementation User

-(void)createWithData:(NSArray *)data{
    
    self.uid =  [NSString stringWithFormat:@"%@", [data valueForKey:@"id"]];
    self.name = [NSString stringWithFormat:@"%@", [data valueForKey:@"name"]];
    self.male = [NSNumber numberWithBool:[[data valueForKey:@"male"] boolValue]];
    self.bday = [NSNumber numberWithInt:[[data valueForKey:@"year"] intValue]];
    self.link = [NSString stringWithFormat:@"%@", [data valueForKey:@"url"]];
}

-(void)createFor:(NSString *)platform withData:(NSDictionary *)data{
    _platform = platform;
    
    if ([platform isEqualToString:Vkontakte]) {
        /*
         bdate
         дата рождения. Возвращается в формате DD.MM.YYYY или DD.MM (если год рождения скрыт). Если дата рождения скрыта целиком, поле отсутствует в ответе.
         
         sex
         
        1 — женский;
        2 — мужской;
        0 — пол не указан.
        */
        _uid = [NSString stringWithFormat:@"%@_%@",Vkontakte,[data objectForKey:@"id"]];
        _name = [data objectForKey:@"first_name"];
        
        if([[data objectForKey:@"sex"] intValue] == 1){ //female
            _male = [NSNumber numberWithInt:0];
        }else if([[data objectForKey:@"sex"] intValue] == 2){ //male
            _male = [NSNumber numberWithInt:1];
        }
        
        _link = [NSString stringWithFormat:@"http://vk.com/%@",[data objectForKey:@"domain"]];
        
        if([data objectForKey:@"bdate"]){
            NSArray *partArray = [[data objectForKey:@"bdate"] componentsSeparatedByString:@"."];
            if(partArray.count == 3){
                //04.19.1980
                _bday = [NSNumber numberWithInt:[partArray[2] intValue]];
            }else if(partArray.count == 2){
                //04/19
            }else if(partArray.count == 1){
                //
            }
        }
        
    }else if([platform isEqualToString:Facebook]){
        
        //The person's birthday. This is a fixed format string, like MM/DD/YYYY. However, people can control who can see the year they were born separately from the month and day so this string can be only the year (YYYY) or the month + day (MM/DD)
        
        //The gender selected by this person, male or female. This value will be omitted if the gender is set to a custom value
        
        _uid = [NSString stringWithFormat:@"%@_%@",Facebook,[data objectForKey:@"id"]];
        _name = [data objectForKey:@"first_name"];
        
        if([data objectForKey:@"gender"]){
            if([[data objectForKey:@"gender"] isEqualToString:@"male"]){ //if not male then 0
                _male = [NSNumber numberWithInt:1];
            }else if([[data objectForKey:@"gender"] isEqualToString:@"female"]){
                _male = [NSNumber numberWithInt:0];
            }
        }
        
        _link = [data objectForKey:@"link"];
        
        if([data objectForKey:@"birthday"]){
            //can be 04/19/1980 || 1980 || 04/19
            
            NSArray *partArray = [[data objectForKey:@"birthday"] componentsSeparatedByString:@"/"];
            if(partArray.count == 3){
                //04/19/1980
                _bday = [NSNumber numberWithInt:[partArray[2] intValue]];
            }else if(partArray.count == 2){
                //04/19
            }else if(partArray.count == 1){
                _bday = [NSNumber numberWithInt:[partArray[0] intValue]];
            }
        }
        
    }
    
//make fake for simulator
#if (TARGET_OS_SIMULATOR)
    
    _uid =  [NSString stringWithFormat:@"test_%@", [Utils randomStringWithLength:10]];
    _name = @"АFakeUser";
    //to check registration
    _male = nil;
    _bday = nil;
    _link = @"http://ancle.ru";
    
#endif
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.uid forKey:@"uid"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.male forKey:@"male"];
    [encoder encodeObject:self.bday forKey:@"bday"];
    [encoder encodeObject:self.link forKey:@"link"];
    [encoder encodeObject:self.platform forKey:@"platform"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.uid = [decoder decodeObjectForKey:@"uid"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.male = [decoder decodeObjectForKey:@"male"];
        self.bday = [decoder decodeObjectForKey:@"bday"];
        self.link = [decoder decodeObjectForKey:@"link"];
        self.platform = [decoder decodeObjectForKey:@"platform"];
    }
    return self;
}

@end
