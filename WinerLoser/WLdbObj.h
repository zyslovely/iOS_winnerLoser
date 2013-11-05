//
//  WLdbObj.h
//  WinerLoser
//
//  Created by Tom on 11/15/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SqlDB_lock.h"

@interface WLdbObj : NSObject {
  
  SqlDB *_db;
  
}

+ (SqlDB *)sharedDB;

@end
