//
//  WLViewController.m
//  WinerLoser
//
//  Created by Tom on 11/15/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import "WLViewController.h"
#import "WLStartNewGameVCTL.h"
#import "WLAppDelegate.h"
#import "WLSummaryTableVCTL.h"
#import "WLSettingsVCTL.h"

@interface WLViewController ()


@end

@implementation WLViewController

- (void)viewDidLoad
{

  [super viewDidLoad];

  self.navigationItem.title = @"打牌计分器";
}

- (void)viewWillAppear:(BOOL)animated {
  
  [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)restartBtnPressed:(id)sender {
  
  if (sender != nil && [[WLAppDelegate currentAttendees] count] != 0) {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"之前进行中的游戏数据将不存在，是否确认重新开始" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    [alertView release];

    return;
  }

  [[WLAppDelegate sharedDelegate] gameRestart];

  WLStartNewGameVCTL *vctl = [[WLStartNewGameVCTL alloc] init];

  [self.navigationController pushViewController:vctl animated:YES];
  [vctl release];

}

- (IBAction)resumeBtnPressed:(id)sender {
  
  if ([[WLAppDelegate currentAttendees] count]==0) {
    [self restartBtnPressed:nil];
    return;
  }
  
  WLSummaryTableVCTL *vctl = [[WLSummaryTableVCTL alloc] init];
  [self.navigationController pushViewController:vctl animated:YES];
  [vctl release];
}

- (IBAction)settingBtnPressed:(id)sender {
  
  WLSettingsVCTL *settings = [[WLSettingsVCTL alloc] init];
  [self.navigationController pushViewController:settings animated:YES];
  [settings release];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  if (buttonIndex == alertView.cancelButtonIndex) {
    return;
  }
  
  if (buttonIndex == 1) {
    
    [self restartBtnPressed:nil];
  }
  
}

@end
