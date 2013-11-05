//
//  WLViewController.h
//  WinerLoser
//
//  Created by Tom on 11/15/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLViewController : UIViewController<UIAlertViewDelegate>

- (IBAction)restartBtnPressed:(id)sender;
- (IBAction)resumeBtnPressed:(id)sender;
- (IBAction)settingBtnPressed:(id)sender;

@end
