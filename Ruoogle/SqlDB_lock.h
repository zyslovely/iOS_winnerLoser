//
//  SqlDB_lock.h
//
//  Created by Chen Jianfei on 11/4/10.
//  Copyright 2010 Fakastudio. All rights reserved.
//  Last Update: Oct 13, 2011

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "Utilities.h"

#define kFieldsDicTypeLongLong  @"LongLong"
#define kFieldsDicTypeInt       @"INTEGER"
#define kFieldsDicTypeText      @"TEXT"
#define kFieldsDicTypeDouble    @"DOUBLE"

#define kFieldsDicNameKey  @"Name"
#define kFieldsDicTypeKey  @"Type"

#define TEXT_FIELD(x) [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:x,kFieldsDicTypeText, nil] forKeys: [NSArray arrayWithObjects:kFieldsDicNameKey, kFieldsDicTypeKey, nil]]

#define INT_FIELD(x) [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:x,kFieldsDicTypeInt, nil] forKeys: [NSArray arrayWithObjects:kFieldsDicNameKey, kFieldsDicTypeKey, nil]]

#define LONGLONG_FIELD(x) [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:x,kFieldsDicTypeLongLong, nil] forKeys: [NSArray arrayWithObjects:kFieldsDicNameKey, kFieldsDicTypeKey, nil]]



//#define DEBUG_OUTPUT	1

@interface SqlDB : NSObject {

  sqlite3 *database;
  NSString *_databaseName;
  NSLock *_dbLock;
}

@property (nonatomic, retain) NSString *databaseName;
@property (nonatomic, retain) NSLock *dbLock;

- (id)initWithDBName:(NSString *)dbName;

// 打开数据库，返回是否成功
- (BOOL)openDatabaseByName:(NSString *)databaseName;

- (BOOL)openDatabase;

// 根据 SQL 语言 返回一个NSArray， 元素都是NSString
- (NSArray *)searchNSStringFieldBySELECT:(NSString *)selectCommand;

// 根据 select xxxxx FROM  xxxx_table  othercommands
// 其中 fieldsNameArray 是个 字段名（NSString*）的数组
- (NSArray *)searchNSStringFieldsBySELECT:(NSArray *)fieldsNameArray from:(NSString *)tableNameStr otherCommands:(NSString *)otherCommands;

// 根据 select xxxxx FROM  xxxx_table  othercommands
// 其中 fieldsDicArray 是个 字段名 as object 字段类型 as key 的 dictionary 数组
- (NSArray *)searchFieldsBySELECT:(NSArray *)fieldsDicArray from:(NSString *)tableNameStr otherCommands:(NSString *)otherCommandStr;

// 返回 select SQL的结果， -1 表示失败
- (double)countOfFieldBySELECT:(NSString *)selectCommand;

// 执行SQL 语句
- (BOOL)runCommandByFullSQL:(NSString *)commandStr;

- (void)closeDatabase;

// 直接调用sqlite3
- (sqlite3 *)database;


// 作为新值存入database, 或更新老值

/* 标准用法举例
 
 PDSqlDB *db = [[PocketDareAppDelegate globalData]sqlDB];
 
 NSArray *fieldNameArray = [[NSArray alloc]initWithObjects: 
 [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:kFieldSmsID, kFieldsDicTypeText,nil] 
 forKeys: [NSArray arrayWithObjects:kFieldsDicNameKey, kFieldsDicTypeKey,nil]],
 
 [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:kFieldSenderID,kFieldsDicTypeText,nil]
 forKeys: [NSArray arrayWithObjects:kFieldsDicNameKey, kFieldsDicTypeKey,nil]],
 
 [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:kFieldReceiveID,kFieldsDicTypeText,nil]
 forKeys: [NSArray arrayWithObjects:kFieldsDicNameKey, kFieldsDicTypeKey,nil]],
 
 [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:kFieldMessageDetail,kFieldsDicTypeText,nil]
 forKeys: [NSArray arrayWithObjects:kFieldsDicNameKey, kFieldsDicTypeKey,nil]],
 
 [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:kFieldCreateDateTime,kFieldsDicTypeText,nil]
 forKeys: [NSArray arrayWithObjects:kFieldsDicNameKey, kFieldsDicTypeKey,nil]],
 
 [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:kFieldStatus,kFieldsDicTypeInt,nil]
 forKeys: [NSArray arrayWithObjects:kFieldsDicNameKey, kFieldsDicTypeKey,nil]],
 
 [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:kFieldType,kFieldsDicTypeInt,nil]
 forKeys: [NSArray arrayWithObjects:kFieldsDicNameKey, kFieldsDicTypeKey,nil]],
 
 [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:kFieldMobileUser,kFieldsDicTypeText,nil]
 forKeys: [NSArray arrayWithObjects:kFieldsDicNameKey, kFieldsDicTypeKey,nil]],							   
 nil];
 
 NSMutableDictionary* dic = [[NSMutableDictionary	alloc]init];
 SET_DICTIONARY_A_OBJ_B_FOR_KEY_C_ONLYIF_B_IS_NOT_NIL(dic, self.smsID, kFieldSmsID);
 SET_DICTIONARY_A_OBJ_B_FOR_KEY_C_ONLYIF_B_IS_NOT_NIL(dic, self.senderUser.userID, kFieldSenderID);
 SET_DICTIONARY_A_OBJ_B_FOR_KEY_C_ONLYIF_B_IS_NOT_NIL(dic, self.receiveUser.userID, kFieldReceiveID);
 SET_DICTIONARY_A_OBJ_B_FOR_KEY_C_ONLYIF_B_IS_NOT_NIL(dic, self.messageDetail, kFieldMessageDetail);
 SET_DICTIONARY_A_OBJ_B_FOR_KEY_C_ONLYIF_B_IS_NOT_NIL(dic, [self.createDateTime pd_yyyyMMddHHmmssString], kFieldCreateDateTime);
 SET_DICTIONARY_A_OBJ_B_FOR_KEY_C_ONLYIF_B_IS_NOT_NIL(dic,[NSNumber numberWithInt:self.status], kFieldStatus);
 SET_DICTIONARY_A_OBJ_B_FOR_KEY_C_ONLYIF_B_IS_NOT_NIL(dic, [NSNumber numberWithInt:self.type], kFieldType);
 SET_DICTIONARY_A_OBJ_B_FOR_KEY_C_ONLYIF_B_IS_NOT_NIL(dic, [PocketDareAppDelegate mobileUserName], kFieldMobileUser);
 
 NSString *whereStr=[[NSString alloc]initWithFormat:@"WHERE %@='%@' ", kFieldSmsID, self.smsID];
 
 [db insertOrUpdateIn:kSqlSMSTbName withFieldArrayName:fieldNameArray withDataDic:dic where:whereStr];
 
 [fieldNameArray release];
 [whereStr release];
 [dic release];
 */

- (long long)insertOrUpdateIn:(NSString *)tableName withFieldArrayName:(NSArray *)fieldNameArray withDataDic:(NSDictionary *)dataDic where:(NSString *)whereString;

// 返回最后插入的row_id
- (NSUInteger)insertIn:(NSString *)tableName withFieldArrayName:(NSArray *)fieldNameArray withDataDic:(NSDictionary *)dataDic;

// update
- (void)updateIn:(NSString *)tableName withFieldArrayName:(NSArray *)fieldNameArray withDataDic:(NSDictionary *)dataDic where:(NSString *)whereString;

// 如果字段都是字符类型的调用
- (void)stringInsertOrUpdateIn:(NSString *)tableName withFieldArrayName:(NSArray *)fieldNameArray withDataDic:(NSDictionary *)dataDic where:(NSString *)whereString;

- (void)stringUpdateIn:(NSString *)tableName withFieldArrayName:(NSArray *)fieldNameArray withDataDic:(NSDictionary *)dataDic where:(NSString *)whereString;


/////// v1.1 自动判断类型方法

// SELECT * from tablenameStr toerhCommandStr
- (NSArray *)searchAllFieldsFrom:(NSString *)tableNameStr otherCommands:(NSString *)otherCommandStr;

/////// v1.2 事务处理
- (void)runTransactionByFullSQL:(NSString *)sql;

/////// v1.3 支持 double, long long 字段类型

-(BOOL)isExistColumnInTable:(NSString *)tableName ColumnName:(NSString *)column;


- (BOOL)isExistIndexInIndexName:(NSString *)indexName;

@end
