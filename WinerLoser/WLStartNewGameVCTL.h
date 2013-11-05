//
//  WLAddUserVCTL.h
//  WinerLoser
//
//  Created by Tom on 11/15/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLStartNewGameVCTL : UIViewController {
  
  UIControl *_maskView;
  NSArray *_pickDataArray;
}

@property (retain, nonatomic) NSMutableArray *selectedUsers;
@property (retain, nonatomic) IBOutlet UITableView *ibSelectedUserTableView;
@property (retain, nonatomic) IBOutlet UITextField *ibUserNameFld;
@property (retain, nonatomic) IBOutlet UIButton *ibGameTypeBtn;
@property (retain, nonatomic) IBOutlet UIPickerView *ibGameTypePicker;
@property (retain, nonatomic) UITextField *ibCardValue;

- (IBAction)addBtnPressed:(id)sender;
- (IBAction)historyBtnPressed:(id)sender;
- (IBAction)viewTouched:(id)sender;
- (IBAction)gameTypePressed:(id)sender;


@end
