//
//  WLgdyScoreCell.m
//  WinerLoser
//
//  Created by Tom on 11/25/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import "WLgdyScoreCell.h"
#import <QuartzCore/QuartzCore.h>
#import "WLAppDelegate.h"
#import "Utilities.h"

@implementation WLgdyScoreCell

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

- (void)dealloc {
  
  [_ibNameLbl     release];
  [_ibWinnerLbl   release];
  [_ibWinnerView  release];
  [_ibScoreLbl    release];
  [_ibCardBtnArray release];
  
  [super dealloc];
}

- (void)awakeFromNib {
  
  [super awakeFromNib];
  [self.ibWinnerView setClipsToBounds:YES];
  [self.ibWinnerView.layer setCornerRadius:5];
}

- (IBAction)cardBtnPressed:(id)sender {
  
  NSUInteger tag = [(UIButton *)sender tag];
  if (tag == self.obj.cardsleft) {
    
    self.obj.cardsleft = 0;
    self.obj.isWinner = YES;
    
  }else {
    
    self.obj.cardsleft = tag;
    self.obj.isWinner = NO;
  }

  [self updateCardsButton:self.obj.cardsleft];
  
  if (_delegate) {
    [_delegate gdyScoreCellCardButtonPressed:self];
  }
}

+ (CGFloat)cellHeight {
  return 70.0f;
}

- (void)updateCardsButton:(NSUInteger)cardsleft {
    
  for (int i=0; i<[_ibCardBtnArray count]; i++) {
    UIButton *btn = [_ibCardBtnArray objectAtIndex:i];
    if (i< cardsleft) {
      [btn setAlpha:1.0];
    }else {
      [btn setAlpha:0.5];
    }
  }
}

- (void)setCellByScoreObj:(WLgdyScoreObj *)obj {
  
  self.obj = obj;
  
  [self updateCardsButton:obj.cardsleft];
  self.ibNameLbl.text = obj.userName;
  self.ibWinnerView.backgroundColor = obj.isWinner?kWinnerColor:kLoserColor;
  self.ibWinnerLbl.text = obj.isWinner?@"赢家":@"输家";
  
  self.ibScoreLbl.text = [Utilities double2string:obj.score];
  self.ibScoreLbl.textColor = obj.isWinner?kWinnerColor:kLoserColor;
}
@end
