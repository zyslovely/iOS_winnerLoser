//
//  WLSummaryCell.m
//  WinerLoser
//
//  Created by Tom on 11/24/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import "WLSummaryCell.h"
#import "WLAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation WLSummaryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib {
  
  [super awakeFromNib];
  _ibUnPaidView.clipsToBounds = YES;
  _ibUnPaidView.layer.cornerRadius = 5;
  
  _ibRoundLoserLimitationView.clipsToBounds = YES;
  _ibRoundLoserLimitationView.layer.cornerRadius = 5;
}

- (void)setCellBySummaryObj:(WLSummaryObj *)summaryObj {
  
  _ibNameLbl.text = summaryObj.userName;

  
  if ([summaryObj.totalScoreString doubleValue] > 0) {
    _ibSummaryLbl.textColor = kWinnerColor;
  }else
    _ibSummaryLbl.textColor = kLoserColor;

  if ([summaryObj.unPaidString doubleValue] > 0) {
    _ibUnpaidLbl.textColor = kWinnerColor;
  }else
    _ibUnpaidLbl.textColor = kLoserColor;
 
    
  _ibSummaryLbl.text = [NSString stringWithFormat:@"%d", (0-[summaryObj.totalScoreString intValue])];
  _ibUnpaidLbl.text = [NSString stringWithFormat:@"%d", (0-[summaryObj.unPaidString intValue])];
  [_ibRoundLoserLimitationView setHidden:!summaryObj.isRoundLimitationReached];
}

- (void)dealloc {
  [_ibNameLbl release];
  [_ibSummaryLbl release];
  [_ibUnpaidLbl release];
  [_ibRoundLoserLimitationView release];
  [_ibUnPaidView release];
  [super dealloc];
}

+ (CGFloat)cellHeight {
  
  return 57;
}
@end
