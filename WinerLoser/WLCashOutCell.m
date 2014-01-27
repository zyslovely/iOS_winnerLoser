//
//  WLCashOutCell.m
//  WinerLoser
//
//  Created by Tom on 11/24/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import "WLCashOutCell.h"
#import "WLCashOutObj.h"
#import "Utilities.h"
#import "WLAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation WLCashOutCell

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
  
  [_ibNameLbl release];
  [_ibShouldLbl release];
  [_ibActualLbl release];
  [_ibActualView release];
  [_ibShouldNumLbl release];
  [_ibActualNumLbl release];
  [super dealloc];
}

- (void)awakeFromNib {
  
  [super awakeFromNib];
  _ibActualView.layer.cornerRadius = 5;
  _ibActualView.clipsToBounds = YES;
}

- (IBAction)clearBtnPressed:(id)sender {
  
  _ibActualNumLbl.text = _ibShouldNumLbl.text;
  self.obj.actualValue = [_ibActualNumLbl.text doubleValue];
  
  if(_delegate){
    [_delegate cashOutCellClearButtonPressed:self];
  }
}

- (void)setCellByCashOutObj:(WLCashOutObj *)cashOutObj {
  
  self.obj = cashOutObj;
  
  _ibNameLbl.text = cashOutObj.userName;
  _ibActualNumLbl.text = cashOutObj.actualValue==0?@"":[Utilities double2string:cashOutObj.actualValue];
  
  if (cashOutObj.isWinner) {
    
    _ibShouldLbl.text = @"应收";
    _ibShouldLbl.textColor = kLoserColor;
    _ibShouldNumLbl.textColor = kLoserColor;
    _ibShouldNumLbl.text = [Utilities double2string:-cashOutObj.shouldValue];
  }else {
    
    _ibShouldLbl.text = @"应付";
    _ibShouldNumLbl.textColor = kWinnerColor;
    _ibShouldLbl.textColor = kWinnerColor;
    _ibShouldNumLbl.text = [Utilities double2string:cashOutObj.shouldValue];
  }
  
  
  if (!cashOutObj.isPayer) {
    
    _ibActualLbl.text = @"收款";
    _ibActualView.backgroundColor = kWinnerColor;
    
  }else {
    
    _ibActualView.backgroundColor = kLoserColor;
    _ibActualLbl.text = @"付款";    
  }
  
  self.selectionStyle = UITableViewCellSelectionStyleGray;
}

- (void)setActualText:(NSString *)text {
  
  _ibActualNumLbl.text = text;
}

- (IBAction)switchPayButtonPressed:(id)sender {
  
  [_delegate cashOutCellSwitchPayButtonPressed:self];
}

+ (CGFloat)cellHeight {
  
  return 59.0f;
}
@end
