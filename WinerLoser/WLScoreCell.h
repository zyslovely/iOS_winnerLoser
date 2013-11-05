//
//  WLScoreCell.h
//  WinerLoser
//
//  Created by Tom on 1/16/13.
//  Copyright (c) 2013 Tom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLScoreObj.h"

@class WLScoreCell;

@protocol WLScoreCellDelegate <NSObject>

- (void)scoreCellWinnerButtonPressed:(WLScoreCell *)cell;

@end

@interface WLScoreCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIButton *ibWinnerBtn;
@property (retain, nonatomic) IBOutlet UILabel *ibNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *ibScoreLbl;
@property (nonatomic, assign) id<WLScoreCellDelegate> delegate;

- (void)setCellByScoreObj:(WLScoreObj *)obj;
- (IBAction)winnerBtnPressed:(id)sender;
+ (CGFloat)cellHeight;

@end
