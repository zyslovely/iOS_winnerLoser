//
//  WLSummaryObj.m
//  WinerLoser
//
//  Created by Tom on 11/24/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import "WLSummaryObj.h"
#import "Utilities.h"
#import "WLdbGameObj.h"
#import "WLAppDelegate.h"
#import "WLdbSettings.h"

@implementation WLSummaryObj

- (void)dealloc {
  
  [_userName release];
  [_totalScoreString release];
  [_unPaidString release];
  
  [super dealloc];
}

- (id)initWithUserID:(NSUInteger )userID userName:(NSString *)userName gameID:(NSString *)gameID {
  
  self = [super init];
  if (self) {
    
    _userID = userID;
    _userName = [userName copy];
    double total = [WLdbGameObj summaryForGameID:gameID userID:userID paid:NO];
    double paid = [WLdbGameObj summaryForGameID:gameID userID:userID paid:YES];
    _unPaidString = [[Utilities double2string:total-paid] copy];
    _totalScoreString = [[Utilities double2string:total] copy];
    
    WLdbSettings *settings = [WLdbSettings defaultSettings];
    if([settings loserHasGapInOneRound]){
      double scoreInRound = [WLdbGameObj summaryForGameID:gameID userID:userID inRound:[WLAppDelegate currentRoundIndex]];
      if (scoreInRound < settings.loserGapInOneRound) {
        _isRoundLimitationReached = NO;
      }else
        _isRoundLimitationReached = YES;
    }

    
  }
  return  self;
}

@end
