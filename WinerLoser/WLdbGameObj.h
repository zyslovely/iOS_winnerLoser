//
//  WLdbGameObj.h
//  WinerLoser
//
//  Created by Tom on 11/15/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLdbObj.h"

@interface WLdbGameObj : WLdbObj

@property (nonatomic, copy) NSString    *gameID;
@property (nonatomic)       NSUInteger  userID;
@property (nonatomic, copy) NSString    *userName;
@property (nonatomic)       NSUInteger  gameIndex;
@property (nonatomic)       NSUInteger  roundIndex;
@property (nonatomic)       float       score;
@property (nonatomic)       BOOL        isPaymentDone;

// 返回某人的 已支付总分 或者 总分
+ (double)summaryForGameID:(NSString *)gameID userID:(NSUInteger) userID paid:(BOOL)paid;

+ (NSArray *)userArrayForCashOutGame:(NSString *)gameID;

// 返回某人在某个回合中的所有总分，用来检查是否超出限制
+ (double)summaryForGameID:(NSString *)gameID userID:(NSUInteger)userID inRound:(NSUInteger)roundIndex;

// 返回在某一局中大家的得分情况
+ (NSArray *)summaryForGameID:(NSString *)gameID withGameNum:(NSUInteger)gameNum;

// 返回在某玩家所有局的情况
+ (NSArray *)userSummaryForGameID:(NSString *)gameID userID:(NSUInteger)userID isCashOut:(BOOL)isCashOutHistory;

// 返回在游戏中所有没有结帐的局数
+ (NSUInteger)numberOfUnpayedGamesForID:(NSString *)gameID;

// 删除一局中所有人的计分
+ (void)removeGameForID:(NSString *)gameID forNum:(NSUInteger)gameNum;

// 结帐
+ (void)cashOutGame:(NSString *)gameID;

- (id)initWithJSONDic:(NSDictionary *)dic;
- (void)saveToDB;

// 清空数据库
+ (void)removeAll;


@end
