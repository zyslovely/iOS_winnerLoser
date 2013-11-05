//
//  WLgdyScoreObj.m
//  WinerLoser
//
//  Created by Tom on 11/25/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import "WLgdyScoreObj.h"

@implementation WLgdyScoreObj

- (id)init {
  
  self = [super init];
  if (self) {
    self.isWinner = YES;
  }
  
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}


@end
