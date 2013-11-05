//
//  WLScoreObj.m
//  WinerLoser
//
//  Created by Tom on 1/16/13.
//  Copyright (c) 2013 Tom. All rights reserved.
//

#import "WLScoreObj.h"
#import "Utilities.h"

@implementation WLScoreObj

- (void)resetScoreString:(double)score {

  self.score = score;
  self.scoreString = [Utilities double2string:self.score];
}

- (void)dealloc {
  
  [_userName release];
  [_scoreString release];
  
  [super dealloc];
}


@end
