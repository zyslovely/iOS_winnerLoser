//
//  WLOneGameVCTL.h
//  WinerLoser
//
//  Created by Tom on 11/16/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLScoreCell.h"

@class WLGameAttendeeView;
@interface WLAddGameScoreVCTL : UIViewController< WLScoreCellDelegate> {
  
  NSMutableArray      *_scoreArray;
}

- (IBAction)keyBtnPressed:(id)sender;

@property (retain, nonatomic) IBOutlet UITableView *ibTableView;


@end
