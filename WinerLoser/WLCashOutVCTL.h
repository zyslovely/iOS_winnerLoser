//
//  WLCashOutVCTL.h
//  WinerLoser
//
//  Created by Tom on 11/24/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLCashOutVCTL : UIViewController {
  
  NSArray *_cashOutSummarArray;
}
@property (retain, nonatomic) IBOutlet UITableView *ibTableView;
- (IBAction)numBtnPressed:(id)sender;

@end
