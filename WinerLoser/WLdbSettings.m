//
//  WLSettings.m
//  WinerLoser
//
//  Created by Tom on 11/24/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import "WLdbSettings.h"

#define kTableName      @"settings"

#define kOnlyOneWinner  @"onlyOneWinner"
#define kLoserHasGap    @"loserHasGap"
#define kLoserGap       @"loserGap"

@implementation WLdbSettings

+ (WLdbSettings *)defaultSettings {
  
  NSString *sql = [NSString stringWithFormat:@"WHERE settings_id = 0"];
  NSArray *arrayOfQuery = [[self sharedDB] searchAllFieldsFrom:kTableName otherCommands:sql];
  WLdbSettings *settings = [[WLdbSettings alloc] initWithDBDic:[arrayOfQuery objectAtIndex:0]];
  return [settings autorelease];
}

+ (NSArray *)allFieldsArray {
  
  return [NSArray arrayWithObjects:
          INT_FIELD(kOnlyOneWinner),
          INT_FIELD(kLoserGap),
          INT_FIELD(kLoserHasGap),
          nil];
}

- (id)initWithDBDic:(NSDictionary *)dic {
  
  self = [super init];
  if (self){
    
    _onlyOneWinner = [[dic objectForKey:kOnlyOneWinner] boolValue];
    _loserHasGapInOneRound = [[dic objectForKey:kLoserHasGap] boolValue];
    _loserGapInOneRound = [[dic objectForKey:kLoserGap] intValue];
  }
  
  return self;
}

- (void)saveDB {
  
  NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
  SET_DICTIONARY_A_OBJ_B_FOR_KEY_C_ONLYIF_B_IS_NOT_NIL(dic,INT2NUM(_onlyOneWinner), kOnlyOneWinner);
  SET_DICTIONARY_A_OBJ_B_FOR_KEY_C_ONLYIF_B_IS_NOT_NIL(dic, INT2NUM(_loserGapInOneRound), kLoserGap);
  SET_DICTIONARY_A_OBJ_B_FOR_KEY_C_ONLYIF_B_IS_NOT_NIL(dic, INT2NUM(_loserHasGapInOneRound), kLoserHasGap);
  
  NSString *whereStr = [NSString stringWithFormat:@"WHERE settings_id = 0"];
  [_db updateIn:kTableName withFieldArrayName:[[self class] allFieldsArray] withDataDic:dic where:whereStr];
  
  [dic release];
}

@end
