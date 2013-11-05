//
//  MYSqlDB_noLock.m
//
//  Created by Chen Jianfei on 11/4/10.
//  Copyright 2010 Fakastudio. All rights reserved.
//  Last Update: Aug 30, 2011

#import "SqlDB_lock.h"

@implementation SqlDB

@synthesize databaseName = _databaseName;
@synthesize dbLock = _dbLock;

#pragma mark -
#pragma mark Private

- (void)insertOrReplaceIn:(NSString *)tableName withFieldArrayName:(NSArray *)fieldNameArray withDataDic:(NSDictionary *)dataDic {

  [self openDatabase];
  [fieldNameArray retain];
  [dataDic retain];

  NSMutableString *commandStr = [[NSMutableString alloc] init];
  [commandStr setString:@"INSERT OR REPLACE INTO "];
  [commandStr appendFormat:@" %@ (", tableName];

  BOOL firstValue = YES;
  NSUInteger valueCount = 0;
  for (int i = 0; i < [fieldNameArray count]; i++) {

    NSString *valueName = [[fieldNameArray objectAtIndex:i] objectForKey:kFieldsDicNameKey];
    if ([dataDic objectForKey:valueName] != nil) {

      valueCount++;
      if (firstValue == YES) {
        [commandStr appendFormat:@" %@", [[fieldNameArray objectAtIndex:i] objectForKey:kFieldsDicNameKey]];
        firstValue = NO;
      } else
        [commandStr appendFormat:@", %@", [[fieldNameArray objectAtIndex:i] objectForKey:kFieldsDicNameKey]];
    }
  }

  [commandStr appendString:@") VALUES ("];

  for (int i = 0; i < valueCount; i++)
    if (i < valueCount - 1) {
      [commandStr appendString:@" ?, "];
    } else
      [commandStr appendString:@" ?);"];

  BOOL getLock = NO;
  while (!getLock) {
    getLock = [self.dbLock tryLock];
  }

  sqlite3_stmt *stmt;
  NSInteger sqlPrepareResult = sqlite3_prepare_v2(database, [commandStr UTF8String], -1, &stmt, nil);


  if (sqlPrepareResult == SQLITE_OK) {

    NSUInteger stamentCount = 1;
    for (int i = 0; i < [fieldNameArray count]; i++) {

      NSDictionary *eachObj = [fieldNameArray objectAtIndex:i];
      NSString *valueType = [eachObj objectForKey:kFieldsDicTypeKey];
      NSString *valueName = [eachObj objectForKey:kFieldsDicNameKey];

      if ([dataDic objectForKey:valueName] != nil) {

        if ([valueType isEqualToString:kFieldsDicTypeText]) {
          sqlite3_bind_text(stmt, stamentCount++, [[dataDic objectForKey:valueName] UTF8String], -1, NULL);
        } else if ([valueType isEqualToString:kFieldsDicTypeInt]) {
          sqlite3_bind_int(stmt, stamentCount++, [[dataDic objectForKey:valueName] intValue]);
        } else if ([valueType isEqualToString:kFieldsDicTypeDouble]) {
          sqlite3_bind_double(stmt, stamentCount++, [[dataDic objectForKey:valueName] doubleValue]);
        } else if ([valueType isEqualToString:kFieldsDicTypeLongLong]) {
          sqlite3_bind_int64(stmt, stamentCount++, [[dataDic objectForKey:valueName] longLongValue]);
        }
      }
    }
    NSInteger sql_result = sqlite3_step(stmt);

    if (sql_result != SQLITE_DONE) {
      NSAssert2(0, @"错误存储数据库中的表格 %@, 错误代码: %d", tableName, sql_result);
    }

    sqlite3_finalize(stmt);
  } else
      NSAssert2(0, @"错误准备存储数据库中的表格 %@, 错误代码: %d", tableName, sqlPrepareResult);

  [self.dbLock unlock];
  [commandStr release];
  [fieldNameArray release];
  [dataDic release];
}

- (void)createEditableCopyOfDatabaseIfNeeded {
  // First, test for existence.
  BOOL success;
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSError *error;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:self.databaseName];
  success = [fileManager fileExistsAtPath:writableDBPath];

  if (success) return;

  // The writable database does not exist, so copy the default to the appropriate location.
  NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseName];
  success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
  if (!success) {
    NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
  }
}

#pragma mark -
#pragma mark Public
- (id)initWithDBName:(NSString *)dbName {

  self = [super init];
  if (self) {

    self.databaseName = dbName;

    [self createEditableCopyOfDatabaseIfNeeded];
    [self openDatabaseByName:dbName];

    NSLock *aLock = [[NSLock alloc] init];
    self.dbLock = aLock;
    [aLock release];
  }

  return self;
}

- (BOOL)openDatabase {

  if (database) {
    return YES;
  }
  return [self openDatabaseByName:self.databaseName];
}


- (BOOL)openDatabaseByName:(NSString *)databaseName {

  //NSString *databaseFilePath = [[NSBundle mainBundle] resourcePath];

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *databaseFilePath = [paths objectAtIndex:0];

  NSString *databaseFileName = [databaseFilePath stringByAppendingPathComponent:databaseName];
  int result = sqlite3_open([databaseFileName UTF8String], &database);

  if (result == SQLITE_OK)
    return YES;
  else
    return NO;
}

- (double)countOfFieldBySELECT:(NSString *)selectCommand {

  [self openDatabase];
  BOOL getLock = NO;
  while (!getLock) {
    getLock = [self.dbLock tryLock];
  }

  sqlite3_stmt *statement;
  int result = sqlite3_prepare_v2(database, [selectCommand UTF8String], -1, &statement, nil);
  if (result == SQLITE_OK) {
    double rowData = 0;

    while (sqlite3_step(statement) == SQLITE_ROW) {
      rowData = sqlite3_column_double(statement, 0);
    }

    sqlite3_finalize(statement);
    [self.dbLock unlock];
    return rowData;

  } else {
    sqlite3_finalize(statement);
    [self.dbLock unlock];
    return -1;
  }
}

- (NSArray *)searchNSStringFieldBySELECT:(NSString *)selectCommand {

  [self openDatabase];

  BOOL getLock = NO;
  while (!getLock) {
    getLock = [self.dbLock tryLock];
  }

  sqlite3_stmt *statement;
  int result = sqlite3_prepare_v2(database, [selectCommand UTF8String], -1, &statement, nil);
  if (result == SQLITE_OK) {

    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];


    while (sqlite3_step(statement) == SQLITE_ROW) {

      char *rowData = (char *) sqlite3_column_text(statement, 0);
      if (rowData) {

        NSString *fieldValue = [[NSString alloc] initWithUTF8String:rowData];

        if (fieldValue)
          [array addObject:fieldValue];
        else
          [array addObject:@""];

        [fieldValue release];
      }
    }
    sqlite3_finalize(statement);
    [self.dbLock unlock];
    return array;
  } else {
    sqlite3_finalize(statement);
    [self.dbLock unlock];
    return nil;
  }
}

- (void)closeDatabase {

  if (database) {
    BOOL getLock = NO;
    while (!getLock) {
      getLock = [self.dbLock tryLock];
    }

    sqlite3_close(database);
    database = nil;
    [self.dbLock unlock];
  }
}

- (NSArray *)searchNSStringFieldsBySELECT:(NSArray *)fieldsNameArray from:(NSString *)tableNameStr otherCommands:(NSString *)otherCommandStr {

  [self openDatabase];

  NSMutableString *selectFields = [[NSMutableString alloc] init];
  for (int i = 0; i < [fieldsNameArray count]; i++)
    if (i < [fieldsNameArray count] - 1) {
      [selectFields appendFormat:@" %@, ", [fieldsNameArray objectAtIndex:i]];
    } else
      [selectFields appendFormat:@" %@ ", [fieldsNameArray objectAtIndex:i]];

  NSString *selectString = [[NSString alloc] initWithFormat:@"SELECT %@ FROM %@ %@", selectFields, tableNameStr, otherCommandStr];


  [selectFields release];

  BOOL getLock = NO;

  while (!getLock) {
    getLock = [self.dbLock tryLock];
  }


  sqlite3_stmt *statement;
  int result = sqlite3_prepare_v2(database, [selectString UTF8String], -1, &statement, nil);

  if (result == SQLITE_OK) {

    NSMutableArray *returnArray = [[NSMutableArray alloc] init];

    while (sqlite3_step(statement) == SQLITE_ROW) {

      NSMutableArray *array = [[NSMutableArray alloc] init];
      for (int i = 0; i < [fieldsNameArray count]; i++) {


        char *rowData = (char *) sqlite3_column_text(statement, i);
        if (rowData) {
          NSString *fieldValue = [[NSString alloc] initWithUTF8String:rowData];

          if (fieldValue)
            [array addObject:fieldValue];
          else
            [array addObject:@""];

          [fieldValue release];
        } else {
          [array addObject:@""];
        }
      }
      [returnArray addObject:array];
      [array release];
    }
    sqlite3_finalize(statement);
    [selectString release];
    [self.dbLock unlock];
    return [returnArray autorelease];

  } else {
    sqlite3_finalize(statement);
    [selectString release];
    [self.dbLock unlock];
    return nil;
  }
}

- (NSArray *)searchAllFieldsFrom:(NSString *)tableNameStr otherCommands:(NSString *)otherCommandStr {

  [self openDatabase];

  NSString *selectString;
  if (tableNameStr) {
    selectString = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ %@", tableNameStr, otherCommandStr];
  }else {
    selectString = [[NSString alloc] initWithString:otherCommandStr];
  }

  BOOL getLock = NO;

  while (!getLock) {
    getLock = [self.dbLock tryLock];
  }


  sqlite3_stmt *statement;
  int result = sqlite3_prepare_v2(database, [selectString UTF8String], -1, &statement, nil);

  if (result == SQLITE_OK) {

    NSMutableArray *returnAry = [[NSMutableArray alloc] init];

    while (sqlite3_step(statement) == SQLITE_ROW) {

      NSMutableDictionary *objDic = [[NSMutableDictionary alloc] init];
      int columnCount = sqlite3_column_count(statement);
      for (int i = 0; i < columnCount; i++) {

        int columnType = sqlite3_column_type(statement, i);
        char *columnName = (char *) sqlite3_column_name(statement, i);
        NSString *columnNameStr = [[NSString alloc] initWithUTF8String:columnName];

        if (columnType == SQLITE_TEXT) {

          char *rowData = (char *) sqlite3_column_text(statement, i);

          if (!rowData) {

            [objDic setObject:@"" forKey:columnNameStr];
          } else {
            NSString *fieldValue = [[NSString alloc] initWithUTF8String:rowData];

            if (fieldValue)
              [objDic setObject:fieldValue forKey:columnNameStr];
            else
              [objDic setObject:@"" forKey:columnNameStr];

            SAFECHECK_RELEASE(fieldValue);
          }

        } else if (columnType == SQLITE_INTEGER) {

          long long rowData = sqlite3_column_int64(statement, i);
          [objDic setObject:[NSNumber numberWithLongLong:rowData] forKey:columnNameStr];
        }
        SAFECHECK_RELEASE(columnNameStr);
      }
      [returnAry addObject:objDic];
      [objDic release];
    }
    sqlite3_finalize(statement);
    [self.dbLock unlock];
    [selectString release];
    return [returnAry autorelease];

  } else {
    sqlite3_finalize(statement);
    [self.dbLock unlock];
    [selectString release];
    NSAssert2(0, @"查询语句错误在数据库 %@, 错误代码: %d", tableNameStr, result);
    return nil;
  }
}

- (NSArray *)searchFieldsBySELECT:(NSArray *)fieldsDicArray from:(NSString *)tableNameStr otherCommands:(NSString *)otherCommandStr {

  [self openDatabase];

  [fieldsDicArray retain];
  NSMutableString *selectFields = [[NSMutableString alloc] init];
  for (int i = 0; i < [fieldsDicArray count]; i++)
    if (i < [fieldsDicArray count] - 1) {
      [selectFields appendFormat:@" %@, ", [[fieldsDicArray objectAtIndex:i] objectForKey:kFieldsDicNameKey]];
    } else
      [selectFields appendFormat:@" %@ ", [[fieldsDicArray objectAtIndex:i] objectForKey:kFieldsDicNameKey]];

  NSString *selectString = [[NSString alloc] initWithFormat:@"SELECT %@ FROM %@ %@", selectFields, tableNameStr, otherCommandStr];

  //CLog(@"In searchFieldsBySELECT, selectString = %@", selectString);

  [selectFields release];

  BOOL getLock = NO;

  while (!getLock) {
    getLock = [self.dbLock tryLock];
  }

  sqlite3_stmt *statement;
  int result = sqlite3_prepare_v2(database, [selectString UTF8String], -1, &statement, nil);

  if (result == SQLITE_OK) {

    NSMutableArray *returnAry = [[NSMutableArray alloc] init];

    while (sqlite3_step(statement) == SQLITE_ROW) {

      NSMutableDictionary *objDic = [[NSMutableDictionary alloc] init];

      for (int i = 0; i < [fieldsDicArray count]; i++) {

        NSString *fieldName = [[fieldsDicArray objectAtIndex:i] objectForKey:kFieldsDicNameKey];
        NSString *fieldType = [[fieldsDicArray objectAtIndex:i] objectForKey:kFieldsDicTypeKey];

        if ([fieldType isEqualToString:kFieldsDicTypeText]) {

          char *rowData = (char *) sqlite3_column_text(statement, i);
          if (!rowData) {

            [objDic setObject:@"" forKey:fieldName];
          } else {
            NSString *fieldValue = [[NSString alloc] initWithUTF8String:rowData];

            if (fieldValue)
              [objDic setObject:fieldValue forKey:fieldName];
            else
              [objDic setObject:@"" forKey:fieldName];

            SAFECHECK_RELEASE(fieldValue);
          }

        } else if ([fieldType isEqualToString:kFieldsDicTypeInt]) {

          int rowData = sqlite3_column_int(statement, i);
          [objDic setObject:[NSNumber numberWithInt:rowData] forKey:fieldName];
        } else if ([fieldType isEqualToString:kFieldsDicTypeDouble]) {

          double rowData = sqlite3_column_double(statement, i);
          [objDic setObject:[NSNumber numberWithDouble:rowData] forKey:fieldName];
        } else if ([fieldType isEqualToString:kFieldsDicTypeLongLong]) {

          long long rowData = sqlite3_column_int64(statement, i);
          [objDic setObject:[NSNumber numberWithLongLong:rowData] forKey:fieldName];
        }
      }
      [returnAry addObject:objDic];
      [objDic release];
    }
    sqlite3_finalize(statement);
    [self.dbLock unlock];
    [fieldsDicArray release];
    [selectString release];
    return [returnAry autorelease];

  } else {
    sqlite3_finalize(statement);
    [self.dbLock unlock];
    [fieldsDicArray release];
    [selectString release];
    NSAssert2(0, @"查询语句错误在数据库 %@, 错误代码: %d", tableNameStr, result);
    return nil;
  }
}


- (sqlite3 *)database {

  return database;
}

- (BOOL)runCommandByFullSQL:(NSString *)commandStr {

  [self openDatabase];


  sqlite3_stmt *statement;

  BOOL getLock = NO;
  while (!getLock) {
    getLock = [self.dbLock tryLock];
  }


  int result = sqlite3_prepare_v2(database, [commandStr UTF8String], -1, &statement, nil);

  if (result == SQLITE_OK) {


    result = sqlite3_step(statement);
    sqlite3_finalize(statement);
    [self.dbLock unlock];

    if (result == SQLITE_DONE)
      return YES;
    else {
      NSAssert1(0, @"错误执行语句, 错误代码: %d", result);
      return NO;
    }
  } else {
    sqlite3_finalize(statement);
    [self.dbLock unlock];
    NSAssert1(0, @"错误执行语句, 错误代码: %d", result);
    return NO;
  }
}

- (void)runTransactionByFullSQL:(NSString *)sql {

  [self openDatabase];

  BOOL getLock = NO;
  while (!getLock) {
    getLock = [self.dbLock tryLock];
  }
  char *errorMsg;
  int result = sqlite3_exec(database, "BEGIN;", 0, 0, &errorMsg);

  if (result == SQLITE_OK) {
    // 执行sql
    result = sqlite3_exec(database, [sql UTF8String], 0, 0, &errorMsg);

    if (result == SQLITE_OK) {
      result = sqlite3_exec(database, "COMMIT;", 0, 0, &errorMsg);

      if (result == SQLITE_OK) {

        [self.dbLock unlock];
        return;   // 执行成功
      }

    }
  }

  [self.dbLock unlock];
  NSAssert1(0, @"错误执行语句, 错误代码: %d", result);
}

- (void)stringInsertOrUpdateIn:(NSString *)tableName withFieldArrayName:(NSArray *)fieldNameArray withDataDic:(NSDictionary *)dataDic where:(NSString *)whereString {

  NSMutableArray *array = [[NSMutableArray alloc] init];

  for (int i = 0; i < [fieldNameArray count]; i++) {

    NSDictionary *dic = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[fieldNameArray objectAtIndex:i], kFieldsDicTypeText, nil]
                                                      forKeys:[NSArray arrayWithObjects:kFieldsDicNameKey, kFieldsDicTypeKey, nil]];
    [array addObject:dic];
    [dic release];
  }

  // 调用通用类型方法
  [self insertOrUpdateIn:tableName withFieldArrayName:array withDataDic:dataDic where:whereString];
  [array release];
}


- (long long)insertOrUpdateIn:(NSString *)tableName withFieldArrayName:(NSArray *)fieldNameArray withDataDic:(NSDictionary *)dataDic where:(NSString *)whereString {

  [self openDatabase];
  [fieldNameArray retain];
  [dataDic retain];

  if (![whereString pd_isNotEmptyString]) {

    [self insertOrReplaceIn:tableName withFieldArrayName:fieldNameArray withDataDic:dataDic];
    [fieldNameArray release];
    [dataDic release];
    return sqlite3_last_insert_rowid(database);
  }

  // 先判断是否存在满足 where 的记录
  NSString *selectStr = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM %@ %@", tableName, whereString];
  NSInteger count = [self countOfFieldBySELECT:selectStr];
  [selectStr release];

  if (count <= 0) {
    
    // 不存在，是用insert OR replace

    [self insertOrReplaceIn:tableName withFieldArrayName:fieldNameArray withDataDic:dataDic];
    [fieldNameArray release];
    [dataDic release];

    return sqlite3_last_insert_rowid(database);    
  } else {
    // 存在 ， 是用Update


    NSMutableString *commandStr = [[NSMutableString alloc] init];
    [commandStr setString:@"UPDATE "];
    [commandStr appendFormat:@" %@ SET ", tableName];

    BOOL firstValue = YES;
    NSUInteger valueCount = 0;
    for (int i = 0; i < [fieldNameArray count]; i++) {

      NSString *valueName = [[fieldNameArray objectAtIndex:i] objectForKey:kFieldsDicNameKey];

      if ([dataDic objectForKey:valueName] != nil) {

        // 如果dataDic 中这个值存在
        valueCount++;
        NSString *fieldName = [[fieldNameArray objectAtIndex:i] objectForKey:kFieldsDicNameKey];
        if (firstValue == YES) {

          [commandStr appendFormat:@" %@ = ? ", fieldName];
          firstValue = NO;
        } else {

          [commandStr appendFormat:@", %@ = ? ", fieldName];

        }
      }
    }

    [commandStr appendFormat:@" %@", whereString];

    //CLog(@"In insert or update, string is '%@'", commandStr);
    //CLog(@"field name dic is %@", [fieldNameArray description]);
    //CLog(@"data dic is %@",[dataDic description]);
    //CLog(@"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");


    BOOL getLock = NO;
    while (!getLock) {
      getLock = [self.dbLock tryLock];
    }

    sqlite3_stmt *stmt;
    NSInteger sqlPrepareResult = sqlite3_prepare_v2(database, [commandStr UTF8String], -1, &stmt, nil);

    if (sqlPrepareResult == SQLITE_OK) {

      NSUInteger stamentCount = 1;

      for (int i = 0; i < [fieldNameArray count]; i++) {

        NSDictionary *eachObj = [fieldNameArray objectAtIndex:i];
        NSString *valueType = [eachObj objectForKey:kFieldsDicTypeKey];
        NSString *valueName = [eachObj objectForKey:kFieldsDicNameKey];

        if ([dataDic objectForKey:valueName] != nil) {

          // 需要进行赋值更新
          if ([valueType isEqualToString:kFieldsDicTypeText]) {
            sqlite3_bind_text(stmt, stamentCount++, [[dataDic objectForKey:valueName] UTF8String], -1, NULL);
          } else if ([valueType isEqualToString:kFieldsDicTypeInt]) {
            sqlite3_bind_int(stmt, stamentCount++, [[dataDic objectForKey:valueName] intValue]);
          } else if ([valueType isEqualToString:kFieldsDicTypeDouble]) {
            sqlite3_bind_double(stmt, stamentCount++, [[dataDic objectForKey:valueName] doubleValue]);
          } else if ([valueType isEqualToString:kFieldsDicTypeLongLong]) {
            sqlite3_bind_int64(stmt, stamentCount++, [[dataDic objectForKey:valueName] longLongValue]);
          }
        }
      }

      NSInteger sql_result = sqlite3_step(stmt);
      if (sql_result != SQLITE_DONE) {

        NSAssert2(0, @"update 发生错误 in %@ with error code: %d", tableName, sql_result);
      }
      sqlite3_finalize(stmt);
    } else {

      NSAssert2(0, @"update  准备错误 in %@ with error code: %d", tableName, sqlPrepareResult);
    }

    [self.dbLock unlock];
    [commandStr release];
    [dataDic release];
    [fieldNameArray release];
    return 0;
  }
}

- (NSUInteger)insertIn:(NSString *)tableName withFieldArrayName:(NSArray *)fieldNameArray withDataDic:(NSDictionary *)dataDic {

  [self openDatabase];
  [fieldNameArray retain];
  [dataDic retain];

  [self insertOrReplaceIn:tableName withFieldArrayName:fieldNameArray withDataDic:dataDic];
  [fieldNameArray release];
  [dataDic release];

  return sqlite3_last_insert_rowid(database);
}

- (void)stringUpdateIn:(NSString *)tableName withFieldArrayName:(NSArray *)fieldNameArray withDataDic:(NSDictionary *)dataDic where:(NSString *)whereString {


  NSMutableArray *array = [[NSMutableArray alloc] init];

  for (int i = 0; i < [fieldNameArray count]; i++) {

    NSDictionary *dic = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[fieldNameArray objectAtIndex:i], kFieldsDicTypeText, nil]
                                                      forKeys:[NSArray arrayWithObjects:kFieldsDicNameKey, kFieldsDicTypeKey, nil]];
    [array addObject:dic];
    [dic release];
  }

  [self updateIn:tableName withFieldArrayName:array withDataDic:dataDic where:whereString];
  [array release];
}

- (void)updateIn:(NSString *)tableName withFieldArrayName:(NSArray *)fieldNameArray withDataDic:(NSDictionary *)dataDic where:(NSString *)whereString {

  [self openDatabase];
  [fieldNameArray retain];
  [dataDic retain];

  // 先判断是否存在满足 where 的记录

  NSString *selectStr = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM %@ %@", tableName, whereString];
  NSInteger count = [self countOfFieldBySELECT:selectStr];
  [selectStr release];

  if (count <= 0) {
    // 不存在，是用insert OR replace
    [dataDic release];
    [fieldNameArray release];
    [self insertIn:tableName withFieldArrayName:fieldNameArray withDataDic:dataDic];
    return;

  } else {
    // 存在 ， 是用Update


    NSMutableString *commandStr = [[NSMutableString alloc] init];
    [commandStr setString:@"UPDATE "];
    [commandStr appendFormat:@" %@ SET ", tableName];

    BOOL firstValue = YES;
    NSUInteger valueCount = 0;
    for (int i = 0; i < [fieldNameArray count]; i++) {

      NSString *valueName = [[fieldNameArray objectAtIndex:i] objectForKey:kFieldsDicNameKey];

      if ([dataDic objectForKey:valueName] != nil) {

        // 如果dataDic 中这个值存在
        valueCount++;
        NSString *fieldName = [[fieldNameArray objectAtIndex:i] objectForKey:kFieldsDicNameKey];
        if (firstValue == YES) {

          [commandStr appendFormat:@" %@ = ? ", fieldName];
          firstValue = NO;
        } else {

          [commandStr appendFormat:@", %@ = ? ", fieldName];

        }
      }
    }

    [commandStr appendFormat:@" %@", whereString];

    //		CLog(@"In insert or update, string is '%@'", commandStr);
    //		CLog(@"field name dic is %@", [fieldNameArray description]);
    //		CLog(@"data dic is %@",[dataDic description]);
    //		CLog(@"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");

    BOOL getLock = NO;
    while (!getLock) {
      getLock = [self.dbLock tryLock];
    }

    sqlite3_stmt *stmt;
    NSInteger sqlPrepareResult = sqlite3_prepare_v2(database, [commandStr UTF8String], -1, &stmt, nil);

    if (sqlPrepareResult == SQLITE_OK) {

      NSUInteger stamentCount = 1;

      for (int i = 0; i < [fieldNameArray count]; i++) {

        NSDictionary *eachObj = [fieldNameArray objectAtIndex:i];
        NSString *valueType = [eachObj objectForKey:kFieldsDicTypeKey];
        NSString *valueName = [eachObj objectForKey:kFieldsDicNameKey];

        if ([dataDic objectForKey:valueName] != nil) {

          // 需要进行赋值更新
          if ([valueType isEqualToString:kFieldsDicTypeText]) {
            sqlite3_bind_text(stmt, stamentCount++, [[dataDic objectForKey:valueName] UTF8String], -1, NULL);
          } else if ([valueType isEqualToString:kFieldsDicTypeInt]) {
            sqlite3_bind_int(stmt, stamentCount++, [[dataDic objectForKey:valueName] intValue]);
          } else if ([valueType isEqualToString:kFieldsDicTypeDouble]) {
            sqlite3_bind_double(stmt, stamentCount++, [[dataDic objectForKey:valueName] doubleValue]);
          } else if ([valueType isEqualToString:kFieldsDicTypeLongLong]) {
            sqlite3_bind_int64(stmt, stamentCount++, [[dataDic objectForKey:valueName] longLongValue]);
          }
        }
      }

      NSInteger sql_result = sqlite3_step(stmt);
      if (sql_result != SQLITE_DONE) {

        NSAssert2(0, @"update 发生错误 in %@ with error code: %d", tableName, sqlPrepareResult);
      }
      sqlite3_finalize(stmt);
    } else {

      NSAssert2(0, @"update  准备错误 in %@ with error code: %d", tableName, sqlPrepareResult);
    }

    [self.dbLock unlock];
    [commandStr release];
    [dataDic release];
    [fieldNameArray release];
  }
}

//判断某表中某字段是否存在
-(BOOL)isExistColumnInTable:(NSString *)tableName ColumnName:(NSString *)column{
  //首先，数据库已经打开
  
  if ((tableName == nil) || (column == nil)) return NO;
  
  sqlite3_stmt *statement = nil;
  
  //NSString * sql = @"PRAGMA table_info([MyAsk_table]) ";
  NSString *sql = [NSString stringWithFormat:@"PRAGMA table_info(%@)", tableName];
  if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK ) {
    CLog(@"Error: failed to prepare statement.");
    [self closeDatabase];
    return NO;
  }
  while (sqlite3_step(statement) == SQLITE_ROW) {
    NSString *columntem = [[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding] autorelease];
    
    CLog(@"columntem = %@", columntem);
    if ([column isEqualToString:columntem]) {
      sqlite3_finalize(statement);
      return YES;
    }
  }
  sqlite3_finalize(statement);
  
  return NO;
}


- (BOOL)isExistIndexInIndexName:(NSString *)indexName{
  
  if (indexName == nil) return NO;
  
  sqlite3_stmt *statement = nil;
  
  NSString *sql = [NSString stringWithFormat:@"select * from sqlite_master where name = '%@'",indexName];
  if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK ) {
    CLog(@"Error: failed to prepare statement.");
    [self closeDatabase];
    return NO;
  }
  while (sqlite3_step(statement) == SQLITE_ROW) {
    NSString *columntem = [[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding] autorelease];
    
    CLog(@"columntem = %@", columntem);
    if ([indexName isEqualToString:columntem]) {
      sqlite3_finalize(statement);
      return YES;
    }
  }
  sqlite3_finalize(statement);
  
  return NO;
  
}

#pragma mark -
#pragma mark Lifecycle
- (void)dealloc {

  [self closeDatabase];
  [_dbLock release];
  [super dealloc];
}

@end
