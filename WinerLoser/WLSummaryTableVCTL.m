//
//  WLSummaryTableViewController.m
//  WinerLoser
//
//  Created by Tom on 11/15/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import "WLSummaryTableVCTL.h"
#import "WLdbGameObj.h"
#import "WLAppDelegate.h"
#import "WLAddGameScoreVCTL.h"
#import "WLGameHistoryVCTL.h"
#import "WLUserHistoryVCTL.h"
#import "Utilities.h"
#import "WLdbUserObj.h"
#import "WLSummaryObj.h"
#import "WLSummaryCell.h"
#import "WLdbSettings.h"
#import "WLCashOutVCTL.h"
#import "WLGameInfo.h"
#import "WLgdyAddGameScoreVCTL.h"

#define kAlertCashoutTag      1001
#define kAlertNeedNewRoundTag 2001

@interface WLSummaryTableVCTL ()
<UIAlertViewDelegate>

@end

@implementation WLSummaryTableVCTL

// 生成summary 数组，并且返回是否需要提示用户新开始一个回合
- (BOOL)generateSummaryArray {
  
  NSUInteger count = 0;
  NSMutableArray *summaryArray = [[NSMutableArray alloc] init];
  for (int i=0; i<[[WLAppDelegate currentAttendees] count]; i++) {
    
    WLdbUserObj *user = [[WLAppDelegate currentAttendees] objectAtIndex:i];
    WLSummaryObj *summary = [[WLSummaryObj alloc] initWithUserID:user.user_id userName:user.user_name gameID:[WLAppDelegate currentGameID]];
    if (summary.isRoundLimitationReached) {
      count++;
    }
    [summaryArray addObject:summary];
    [summary release];
  }
  self.summaryArray = summaryArray;
  [summaryArray release];
  
  if (count == [self.summaryArray count]-1) {
    return YES;
  }
  
  return NO;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"记录比分" style:UIBarButtonItemStyleDone target:self action:@selector(addRecord:)] autorelease];
  
  if(!_summaryArray)
    _summaryArray = [[NSMutableArray alloc] init];
  
  self.navigationItem.title = @"目前总成绩";
}

- (void)viewWillAppear:(BOOL)animated {
  
  [super viewWillAppear:animated];
  
  self.navigationController.navigationBarHidden = NO;
  BOOL needNewRound = [self generateSummaryArray];
  if (needNewRound) {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否需要开始新的一轮回合?" message:@"除了一位参与者，其他人都已经到达输家上限" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"开始新回合", nil];
    alertView.tag = kAlertNeedNewRoundTag;
    [alertView show];
    [alertView release];
  }
  [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
  
  
  [super viewDidAppear:animated];
  
  
  if([WLAppDelegate currentGameIndex] == 0 && !didShowOnce) {
    // 直接进入输入分数界面
    [self addRecord:nil];
    didShowOnce = YES;
  }
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
  SAFECHECK_RELEASE(_summaryArray);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
  if (section == 1) {
    return [_summaryArray count];
  }else {
    
    if ([[WLdbSettings defaultSettings] loserHasGapInOneRound]) {
      return 3;
    }else
      return 2;
  }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  if ([indexPath section] == 1) {
    WLSummaryObj *summary = [_summaryArray objectAtIndex:[indexPath row]];
    WLSummaryCell *cell = (WLSummaryCell*)[Utilities cellByClassName:@"WLSummaryCell" inNib:@"TableViewCell" forTableView:self.tableView];
    [cell setCellBySummaryObj:summary];
    return cell;
  }
  
  
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
  }
  
  if([indexPath row] == 0) {
    cell.textLabel.text = @"查看每局历史";
    cell.detailTextLabel.text = [WLAppDelegate currentGameIndex]==0?@"还没有开始":[NSString stringWithFormat:@"已经玩了%d局", [WLAppDelegate currentGameIndex]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  if ([indexPath row] == 1) {
    cell.textLabel.text = @"去结帐";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  if ([indexPath row] == 2) {
    cell.textLabel.text = @"点击开始新的回合";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"当前是第%d回合",[WLAppDelegate currentRoundIndex]];
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  
  return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  
  if (section == 1) {
    return @"为了方便记录，负分代表赢";
  }else
    return @"";
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if ([indexPath section] == 0) {
    return 44.0;
  }
  
  return [WLSummaryCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if ([indexPath section]== 0) {
    
    if ([indexPath row] == 0) {
      
      if ([WLAppDelegate currentGameIndex] == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
      }
      
      WLGameHistoryVCTL *vctl = [[WLGameHistoryVCTL alloc] init];
      vctl.showingGameNum = [WLAppDelegate currentGameIndex];
      [self.navigationController pushViewController:vctl animated:YES];
      [vctl release];      
    }
    
    
    if ([indexPath row] == 1) {
      
      // 结帐
      WLCashOutVCTL *vctl = [[WLCashOutVCTL alloc] init];
      [self.navigationController pushViewController:vctl animated:YES];
      [vctl release];
    }
    
    if ([indexPath row] == 2) {
      
      // 增加回合
      [WLAppDelegate increaseRoundIndex];
      if ([[WLdbSettings defaultSettings] loserHasGapInOneRound]) {
        
        [Utilities alertWithOK:@"开始新的回合，所有的限额将会被重置"];
      }else {
        [Utilities alertWithOK:@"开始新的回合"];
      }
      
      [self.tableView reloadData];
      [self addRecord:0];
    }
    
    
  }else {
    
    WLUserHistoryVCTL *vctl = [[WLUserHistoryVCTL alloc] init];
    WLdbGameObj *obj = [self.summaryArray objectAtIndex:[indexPath row]];
    vctl.userName = obj.userName;
    vctl.userID = obj.userID;
    vctl.userIndex = [indexPath row];
    [self.navigationController pushViewController:vctl animated:YES];
    [vctl release];
  }
  
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)addRecord:(id)sender {

  WLGameInfo *info = [[WLAppDelegate sharedDelegate] gameInfo];
  
  if (info.type == WL_GAME_NORMAL) {
    WLAddGameScoreVCTL *vctl = [[WLAddGameScoreVCTL alloc] init];
    [self.navigationController pushViewController:vctl animated:YES];
    [vctl release];
  }
  
  if (info.type == WL_GAME_GAN_DENG_YAN) {
    WLgdyAddGameScoreVCTL *vctl = [[WLgdyAddGameScoreVCTL alloc] init];
    [self.navigationController pushViewController:vctl animated:YES];
    [vctl release];
  }
  
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  if (alertView.cancelButtonIndex == buttonIndex) {
    return;
  }
  
  if(alertView.tag == kAlertCashoutTag){
    
    [WLdbGameObj cashOutGame:[WLAppDelegate currentGameID]];
    [self generateSummaryArray];
    [self.tableView reloadData];
  }
  
  
  if (alertView.tag == kAlertNeedNewRoundTag) {
    
    [WLAppDelegate increaseRoundIndex];
    [self generateSummaryArray];
    [self.tableView reloadData];
  }
}
@end
