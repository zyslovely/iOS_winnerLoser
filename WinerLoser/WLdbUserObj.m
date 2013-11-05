//
//  WLUserObj.m
//  WinerLoser
//
//  Created by Tom on 11/15/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import "WLdbUserObj.h"

#define kTableName    @"user"
#define kUserName     @"user_name"
#define kUserID       @"user_id"

@implementation WLdbUserObj


+ (NSArray*)allFieldsArray {
  
	NSArray *fieldsArray = [NSArray arrayWithObjects:
                          TEXT_FIELD(kUserName),
                          INT_FIELD(kUserID),nil];
  
  return fieldsArray;
}


- (void)saveToDB {

  NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
  
	SET_DICTIONARY_A_OBJ_B_FOR_KEY_C_ONLYIF_B_IS_NOT_NIL(dataDic, INT2STR(self.user_id),kUserID);
	SET_DICTIONARY_A_OBJ_B_FOR_KEY_C_ONLYIF_B_IS_NOT_NIL(dataDic, self.user_name, kUserName);
  
	NSString *whereStr=[[NSString alloc]initWithFormat:@"WHERE %@=%d ", kUserID,self.user_id];
  
  if (_user_id == 0) {
    
    // 新用户
    SAFECHECK_RELEASE(whereStr);
    [dataDic removeObjectForKey:kUserID];
    _user_id = [_db insertIn:kTableName withFieldArrayName:[[self class] allFieldsArray]	withDataDic:dataDic];
    
  }else {
  
    [_db insertOrUpdateIn:kTableName withFieldArrayName:[[self class] allFieldsArray]	withDataDic:dataDic where:whereStr];
	}
  
	[whereStr release];
	[dataDic release];
  
}

- (void)dealloc {
  
  [_user_name release];
  [super dealloc];
}

- (id)initWithJSONDic:(NSDictionary *)dic {
  
  self = [super init];
  if (self) {
    
    _user_id = [[dic objectForKey:kUserID] intValue];
    _user_name = [[dic objectForKey:kUserName] copy];
    
  }
  return self;
}

#pragma mark - NSCoding, NSCopying
- (void)encodeWithCoder:(NSCoder *)aCoder {
  
  [aCoder encodeInt:self.user_id forKey:kUserID];
  [aCoder encodeObject:self.user_name forKey:kUserName];
  
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  
  self = [super init];
  
  if (self) {
    
    _user_id = [aDecoder decodeIntForKey:kUserID];
    _user_name = [[aDecoder decodeObjectForKey:kUserName] copy];
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  
  WLdbUserObj *copy = [[[self class] allocWithZone:zone] init];
  
  copy.user_id = self.user_id;
  copy.user_name = [[self.user_name copyWithZone:zone] autorelease];
  return copy;
}


+ (NSArray *)arrayWithAllUsers {
  
  NSMutableArray *resultArray = [[NSMutableArray alloc] init];
  
  NSArray *queryResult = [[self sharedDB] searchAllFieldsFrom:kTableName otherCommands:@""];
  for (NSDictionary *dic in queryResult) {
    WLdbUserObj *userObj = [[WLdbUserObj alloc] initWithJSONDic:dic];
    [resultArray addObject:userObj];
    [userObj release];
  }
  return [resultArray autorelease];
}

+ (BOOL)findUserByID:(NSUInteger)userID {
  
  NSUInteger count = [[self sharedDB] countOfFieldBySELECT:[NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@ = %d", kTableName, kUserID, userID]];
  return count>0;
}

+ (void)removeAll {
  
  [[self sharedDB] runCommandByFullSQL:[NSString stringWithFormat:@"DELETE FROM %@", kTableName]];
}

@end
