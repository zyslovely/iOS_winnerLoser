//
//  WLUserHistoryVCTL.h
//  WinerLoser
//
//  Created by Tom on 11/17/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLUserHistoryVCTL : UIViewController

@property (nonatomic, retain)   NSArray *userScoreInOneGameArray;
@property (nonatomic, retain)   NSArray *userCashOutHistoryArray;

@property (retain, nonatomic) IBOutlet UITableView *ibTableView;

@property (nonatomic, copy) NSString *userName;
@property (nonatomic) NSUInteger userID;
@property (nonatomic) NSUInteger userIndex;

@end
