//
//  WLSettings.h
//  WinerLoser
//
//  Created by Tom on 11/24/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLdbObj.h"

@interface WLdbSettings: WLdbObj

@property (nonatomic) BOOL        onlyOneWinner;
@property (nonatomic) BOOL        loserHasGapInOneRound;
@property (nonatomic) NSInteger   loserGapInOneRound;

+ (WLdbSettings *)defaultSettings;
- (void)saveDB;
@end
