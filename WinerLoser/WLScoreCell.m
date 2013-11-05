//
//  WLScoreCell.m
//  WinerLoser
//
//  Created by Tom on 1/16/13.
//  Copyright (c) 2013 Tom. All rights reserved.
//

#import "WLScoreCell.h"
#import "WLAppDelegate.h"
#import "Utilities.h"

@implementation WLScoreCell

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
  
  self.selectedBackgroundView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
  self.selectedBackgroundView.backgroundColor = [UIColor greenColor];
}

- (void)dealloc {
  
  [_ibWinnerBtn release];
  [_ibNameLbl release];
  [_ibScoreLbl release];
  [super dealloc];
}

- (void)setCellByScoreObj:(WLScoreObj *)obj {
  
  BOOL isWinner = obj.isWinner;
  
  [self.ibWinnerBtn setTitle:isWinner?@"赢家":@"输家" forState:UIControlStateNormal];
  [self.ibWinnerBtn setTitleColor:isWinner?kWinnerColor:kLoserColor forState:UIControlStateNormal];
  self.ibScoreLbl.textColor =isWinner?kWinnerColor:kLoserColor;
  self.ibNameLbl.textColor = isWinner?kWinnerColor:kLoserColor;
  
  self.ibNameLbl.text = obj.userName;
  self.ibScoreLbl.text = obj.scoreString;
  
  if (obj.selected) {
    self.contentView.backgroundColor = [UIColor greenColor];
  }else {
    self.contentView.backgroundColor = [UIColor whiteColor];
  }
}

- (IBAction)winnerBtnPressed:(id)sender {
  
  if (_delegate) {
    [_delegate scoreCellWinnerButtonPressed:self];
  }
}

+ (CGFloat)cellHeight {
  
  return 55.0f + 1.0f;
}
@end
