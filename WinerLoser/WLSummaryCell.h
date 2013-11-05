//
//  WLSummaryCell.h
//  WinerLoser
//
//  Created by Tom on 11/24/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLSummaryObj.h"

@interface WLSummaryCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *ibNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *ibSummaryLbl;
@property (retain, nonatomic) IBOutlet UILabel *ibUnpaidLbl;
@property (retain, nonatomic) IBOutlet UIView *ibRoundLoserLimitationView;
@property (retain, nonatomic) IBOutlet UIView *ibUnPaidView;

- (void)setCellBySummaryObj:(WLSummaryObj *)summaryObj;
+ (CGFloat)cellHeight;

@end
