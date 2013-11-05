//
//  WLdbGameObj.m
//  WinerLoser
//
//  Created by Tom on 11/15/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import "WLdbGameObj.h"
#import "WLAppDelegate.h"
#import "WLdbUserObj.h"
#import "WLCashOutObj.h"

#define kTableName    @"game"

#define kUserID       @"user_id"
#define kUserName     @"user_name"
#define kGameID       @"game_id"
#define kGameIndex    @"game_index"
#define kRoundIndex   @"round_index"
#define kPaymentDone  @"is_payment_done"
#define kSCore        @"score"

@implementation WLdbGameObj

- (void)dealloc {
  
  
  [_gameID release];
  [_userName release];
  
  [super dealloc];
}

+ (NSArray*)allFieldsArray {
  
	NSArray *fieldsArray = [NSArray arrayWithObjects:
                          TEXT_FIELD(kUserName),
                          TEXT_FIELD(kGameID),
                          INT_FIELD(kUserID),
                          INT_FIELD(kGameIndex),
                          TEXT_FIELD(kSCore),
                          INT_FIELD(kRoundIndex),
                          INT_FIELD(kPaymentDone),
                          nil];
  
  return fieldsArray;
}

- (void)saveToDB {
  
  NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
  
	SET_DICTIONARY_A_OBJ_B_FOR_KEY_C_ONLYIF_B_IS_NOT_NIL(dataDic, INT2STR(self.userID),kUserID);
	SET_DICTIONARY_A_OBJ_B_FOR_KEY_C_ONLYIF_B_IS_NOT_NIL(dataDic, self.userName, kUserName);
  SET_DICTIONARY_A_OBJ_B_FOR_KEY_C_ONLYIF_B_IS_NOT_NIL(dataDic, self.gameID, kGameID);
  SET_DICTIONARY_A_OBJ_B_FOR_KEY_C_ONLYIF_B_IS_NOT_NIL(dataDic, INT2STR(self.gameIndex), kGameIndex);
  SET_DICTIONARY_A_OBJ_B_FOR_KEY_C_ONLYIF_B_IS_NOT_NIL(dataDic, [Utilities double2string:self.score], kSCore);
  SET_DICTIONARY_A_OBJ_B_FOR_KEY_C_ONLYIF_B_IS_NOT_NIL(dataDic, INT2NUM(self.roundIndex), kRoundIndex);
  SET_DICTIONARY_A_OBJ_B_FOR_KEY_C_ONLYIF_B_IS_NOT_NIL(dataDic, INT2NUM(self.isPaymentDone), kPaymentDone);
  
	NSString *whereStr=[[NSString alloc]initWithFormat:@"WHERE %@=%d AND %@='%@' AND %@=%d ",
                      kUserID,self.userID,
                      kGameID, self.gameID,
                      kGameIndex, self.gameIndex];
	[_db insertOrUpdateIn:kTableName withFieldArrayName:[[self class] allFieldsArray]	withDataDic:dataDic where:whereStr];
	[whereStr release];
	[dataDic release];
}

- (id)initWithJSONDic:(NSDictionary *)dic {
  
  self = [super init];
  if (self) {
    
    _userID = [[dic objectForKey:kUserID] intValue];
    _userName = [[dic objectForKey:kUserName] copy];
    _gameID = [[dic objectForKey:kGameID] copy];
    _gameIndex = [[dic objectForKey:kGameIndex] intValue];
    _roundIndex = [[dic objectForKey:kRoundIndex] intValue];
    _score = [[dic objectForKey:kSCore] doubleValue];
    _isPaymentDone = [[dic objectForKey:kPaymentDone] intValue];
    
  }
  return self;
}

// 返回某人的 已支付总分 或者 总分
+ (double)summaryForGameID:(NSString *)gameID userID:(NSUInteger) userID paid:(BOOL)paid{

    
  NSString *sql = [NSString stringWithFormat:@"SELECT SUM(%@) FROM %@ WHERE %@ = %d AND %@ = '%@' AND %@ = %d",
                   kSCore,
                   kTableName,
                   kUserID, userID,
                   kGameID, gameID,
                   kPaymentDone, paid];
  double totalScore = [[self sharedDB] countOfFieldBySELECT:sql];
    
  return totalScore;
}

+ (NSArray *)userArrayForCashOutGame:(NSString *)gameID {
  
  NSMutableArray *array = [[NSMutableArray alloc] init];
  
  for (int i=0; i<[[WLAppDelegate currentAttendees] count]; i++) {
    WLdbUserObj *user = [[WLAppDelegate currentAttendees] objectAtIndex:i];
    
    NSString *sql_1 = [NSString stringWithFormat:@"SELECT SUM(%@) FROM %@ WHERE %@ = '%@' AND %@ = %d AND %@ = 0", kSCore,
                     kTableName,
                     kGameID, gameID,
                     kUserID, user.user_id,
                     kPaymentDone];
    NSString *sql_2 = [NSString stringWithFormat:@"SELECT SUM(%@) FROM %@ WHERE %@ = '%@' AND %@ = %d AND %@ = 1", kSCore,
                       kTableName,
                       kGameID, gameID,
                       kUserID, user.user_id,
                       kPaymentDone];
    
    double value_1 = [[self sharedDB] countOfFieldBySELECT:sql_1];
    double value_2 = [[self sharedDB] countOfFieldBySELECT:sql_2];
    
    WLCashOutObj *summary = [[WLCashOutObj alloc] init];
    summary.userID = user.user_id;
    summary.userName = user.user_name;
    summary.shouldValue = value_1-value_2;
    summary.actualValue = 0;
    
    if (summary.shouldValue >= 0) {
      summary.isWinner = NO;
      summary.isPayer = YES;
    }else {
      summary.isWinner = YES;
      summary.isPayer = NO;
    }
    
    [array addObject:summary];
    [summary release];
  }
  
  return [array autorelease];
}

// 返回某人在某个回合中的所有总分，用来检查是否超出限制
+ (double)summaryForGameID:(NSString *)gameID userID:(NSUInteger)userID inRound:(NSUInteger)roundIndex {
  
  NSString *sql = [NSString stringWithFormat:@"SELECT SUM(%@) FROM %@ WHERE %@ = %d AND %@ = '%@' AND %@=%d",
                   kSCore,
                   kTableName,
                   kUserID, userID,
                   kGameID, gameID,
                   kRoundIndex, roundIndex];
  double totalScore = [[self sharedDB] countOfFieldBySELECT:sql];
  
  return totalScore;
}

// 返回在某一局中大家的得分情况
+ (NSArray *)summaryForGameID:(NSString *)gameID withGameNum:(NSUInteger)gameNum {
  
  NSMutableArray *resultArray = [[NSMutableArray alloc] init];
  
    
  NSString *sql = [NSString stringWithFormat:@"WHERE %@='%@' AND %@=%d", kGameID, gameID, kGameIndex, gameNum];
  
  NSArray *sqlDicArray = [[self sharedDB] searchAllFieldsFrom:kTableName otherCommands:sql];
  for (NSDictionary *dic in sqlDicArray) {
    
    WLdbGameObj *gameObj = [[WLdbGameObj alloc] initWithJSONDic:dic];
    [resultArray addObject:gameObj];
    [gameObj release];
  }

  return [resultArray autorelease];
}

// 返回在某玩家所有局的情况
+ (NSArray *)userSummaryForGameID:(NSString *)gameID userID:(NSUInteger)userID isCashOut:(BOOL)isCashOutHistory {
  
  NSMutableArray *resultArray = [[NSMutableArray alloc] init];
  NSString *sql;
  if (!isCashOutHistory) {
     sql= [NSString stringWithFormat:@"WHERE %@='%@' AND %@=%d AND  %@>0 ORDER BY %@ ASC",
                     kGameID, gameID,
                     kUserID, userID,
                     kGameIndex,
                     kGameIndex];
  }else {
     sql = [NSString stringWithFormat:@"WHERE %@='%@' AND %@=%d AND  %@<0 ORDER BY %@ DESC",
                     kGameID, gameID,
                     kUserID, userID,
                     kGameIndex,
                     kGameIndex];
  }
  NSArray *sqlDicArray = [[self sharedDB] searchAllFieldsFrom:kTableName otherCommands:sql];
  for (NSDictionary *dic in sqlDicArray) {
    
    WLdbGameObj *gameObj = [[WLdbGameObj alloc] initWithJSONDic:dic];
    [resultArray addObject:gameObj];
    [gameObj release];
  }
  
  return [resultArray autorelease];
}

// 返回在游戏中所有没有结帐的局数
+ (NSUInteger)numberOfUnpayedGamesForID:(NSString *)gameID {
  
  NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(DISTINCT %@) FROM %@ WHERE %@='%@' AND %@ = 0",
                   kGameIndex, kTableName,
                   kGameID, gameID, kPaymentDone];
  return [[self sharedDB] countOfFieldBySELECT:sql];
}

// 删除一局中所有人的计分
+ (void)removeGameForID:(NSString *)gameID forNum:(NSUInteger)gameNum {
  
  [[self sharedDB] runCommandByFullSQL:[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@='%@' AND %@=%d", kTableName, kGameID, gameID, kGameIndex, gameNum]];
  [[self sharedDB] runCommandByFullSQL:[NSString stringWithFormat:@"UPDATE %@ SET %@= %@ -1 WHERE %@='%@' AND %@ > %d", kTableName,
                                        kGameIndex,kGameIndex,
                                        kGameID, gameID,kGameIndex,gameNum]];
  [WLAppDelegate decreaseGameIndex];
}

+ (void)cashOutGame:(NSString *)gameID {
  
  NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ = 1 WHERE %@ = '%@'", kTableName,
                   kPaymentDone, kGameID, gameID];
  [[self sharedDB] runCommandByFullSQL:sql];
}

// 清空数据库
+ (void)removeAll {
  
  [[self sharedDB] runCommandByFullSQL:[NSString stringWithFormat:@"DELETE FROM %@", kTableName]];
}
@end
