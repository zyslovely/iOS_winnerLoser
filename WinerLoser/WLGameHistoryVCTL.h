//
//  WLHistoryAllVCTL.h
//  WinerLoser
//
//  Created by Tom on 11/17/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLGameHistoryVCTL : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSArray  *gameObjArray;

@property (retain, nonatomic) IBOutlet UIToolbar *ibToolbar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *ibLeftItem;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *ibRightItem;
@property (retain, nonatomic) IBOutlet UITableView *ibTableView;
@property (nonatomic) NSUInteger                   showingGameNum;

- (IBAction)nextGamePressed:(id)sender;
- (IBAction)prevGamePressed:(id)sender;

@end
