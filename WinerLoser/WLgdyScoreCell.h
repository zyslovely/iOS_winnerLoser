//
//  WLgdyScoreCell.h
//  WinerLoser
//
//  Created by Tom on 11/25/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLgdyScoreObj.h"

@class WLgdyScoreCell;
@protocol  WLgdyScoreCellDelegate <NSObject>

- (void)gdyScoreCellCardButtonPressed:(WLgdyScoreCell *)cell;

@end

@interface WLgdyScoreCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *ibNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *ibWinnerLbl;
@property (retain, nonatomic) IBOutlet UIView *ibWinnerView;
@property (retain, nonatomic) IBOutlet UILabel *ibScoreLbl;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *ibCardBtnArray;
@property (nonatomic, retain) WLgdyScoreObj *obj;
@property (nonatomic, assign) id <WLgdyScoreCellDelegate>delegate;

- (IBAction)cardBtnPressed:(id)sender;

+ (CGFloat)cellHeight;
- (void)setCellByScoreObj:(WLgdyScoreObj *)obj;
@end
