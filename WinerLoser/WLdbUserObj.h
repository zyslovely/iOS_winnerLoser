//
//  WLUserObj.h
//  WinerLoser
//
//  Created by Tom on 11/15/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLdbObj.h"

@interface WLdbUserObj : WLdbObj <NSCoding, NSCopying>

@property (nonatomic) NSUInteger user_id;
@property (nonatomic, copy)NSString *user_name;


- (void)saveToDB;
- (id)initWithJSONDic:(NSDictionary *)dic;
+ (NSArray *)arrayWithAllUsers;
+ (BOOL)findUserByID:(NSUInteger)userID;
+ (void)removeAll;

@end
