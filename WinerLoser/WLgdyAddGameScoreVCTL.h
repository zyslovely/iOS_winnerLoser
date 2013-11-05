//
//  WLGDYAddGameScoreVCTL.h
//  WinerLoser
//
//  Created by Tom on 11/25/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLgdyAddGameScoreVCTL : UIViewController {
  
  NSUInteger _factor;
  NSInteger _doubeBtnIndexSelected;
  NSMutableArray *_scoreArray;
}

@property (retain, nonatomic) IBOutlet UILabel *ibScoreInGameLbl;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *ibDoubleBtnArray;
@property (retain, nonatomic) IBOutlet UITableView *ibTableView;

- (IBAction)doubleBtnPressed:(id)sender;

@end
