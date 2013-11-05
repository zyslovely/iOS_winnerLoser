//
//  WLdbObj.m
//  WinerLoser
//
//  Created by Tom on 11/15/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import "WLdbObj.h"

static SqlDB *__sharedDB;

@implementation WLdbObj

- (id)init {
  
  self = [super init];
  if  (self){

    _db = [[[self class] sharedDB] retain];
    
  }

  return self;
}

- (void)dealloc {
  
  
  [_db release];
  
  [super dealloc];
}



+ (SqlDB *)sharedDB {
  

  if (!__sharedDB) {
    __sharedDB = [[SqlDB alloc] initWithDBName:@"mainDB.sqlite"];
  }
  
  return __sharedDB;
}

@end
