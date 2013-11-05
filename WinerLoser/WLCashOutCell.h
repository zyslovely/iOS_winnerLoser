//
//  WLCashOutCell.h
//  WinerLoser
//
//  Created by Tom on 11/24/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import <UIKit/UIKit.h>


@class WLCashOutObj;
@class WLCashOutCell;

@protocol WLCashOutCellDelegate <NSObject>

- (void)cashOutCellClearButtonPressed:(WLCashOutCell *)cell;
- (void)cashOutCellSwitchPayButtonPressed:(WLCashOutCell *)cell;

@end
@interface WLCashOutCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *ibNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *ibShouldLbl;
@property (retain, nonatomic) IBOutlet UILabel *ibActualLbl;
@property (retain, nonatomic) IBOutlet UIView *ibActualView;
@property (retain, nonatomic) IBOutlet UILabel *ibShouldNumLbl;
@property (retain, nonatomic) IBOutlet UILabel *ibActualNumLbl;
@property (nonatomic, retain) WLCashOutObj *obj;
@property (nonatomic, assign) id <WLCashOutCellDelegate> delegate;

- (IBAction)clearBtnPressed:(id)sender;
- (void)setCellByCashOutObj:(WLCashOutObj *)cashOutObj;
- (void)setActualText:(NSString *)text;
- (IBAction)switchPayButtonPressed:(id)sender;

+ (CGFloat)cellHeight;

@end
