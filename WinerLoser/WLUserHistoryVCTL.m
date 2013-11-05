//
//  WLUserHistoryVCTL.m
//  WinerLoser
//
//  Created by Tom on 11/17/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import "WLUserHistoryVCTL.h"
#import "WLAppDelegate.h"
#import "WLdbGameObj.h"
#import "WLdbUserObj.h"
#import "WLGameHistoryVCTL.h"

@interface WLUserHistoryVCTL ()

@end

@implementation WLUserHistoryVCTL

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.navigationItem.rightBarButtonItem= [[[UIBarButtonItem alloc] initWithTitle:@"下一个人" style:UIBarButtonItemStyleBordered target:self action:@selector(next:)] autorelease];
}

- (void)viewDidAppear:(BOOL)animated {
  
  [super viewDidAppear:animated];
  
  [self reloadTableData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  
  [_userName release];
  [_ibTableView release];
  [super dealloc];
}

- (void)viewDidUnload {
    [self setIbTableView:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  if ([_userCashOutHistoryArray count]>0) {
    return 2;
  }
  
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // Return the number of rows in the section.
  if(section == 0)
    return [_userScoreInOneGameArray count];
  
  return [_userCashOutHistoryArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
  }

  if ([indexPath section] == 0) {
    
    WLdbGameObj *obj = [_userScoreInOneGameArray objectAtIndex:[indexPath row]];
    cell.textLabel.text = [NSString stringWithFormat:@"第%d局", obj.gameIndex];
    if (obj.score > 0) {
      cell.detailTextLabel.textColor = kLoserColor;
    }else {
      cell.detailTextLabel.textColor = kWinnerColor;
    }
    
    if (obj.score == 0) {
      cell.detailTextLabel.text = @"平";
      cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    
    if (obj.score > 0) {
      cell.detailTextLabel.text = [NSString stringWithFormat:@"输了 %@", [Utilities double2string:obj.score]];
    }
    
    if (obj.score < 0) {
      cell.detailTextLabel.text = [NSString stringWithFormat:@"赢了 %@", [Utilities double2string:-obj.score]];
    }
  }
  
  if ([indexPath section] == 1) {
    
    WLdbGameObj *obj = [_userCashOutHistoryArray objectAtIndex:[indexPath row]];
    cell.textLabel.text = [NSString stringWithFormat:@"第%d次", -obj.gameIndex];
    if (obj.score > 0) {
      cell.detailTextLabel.textColor = kLoserColor;
    }else {
      cell.detailTextLabel.textColor = kWinnerColor;
    }
    
    if (obj.score == 0) {
      cell.detailTextLabel.text = @"平";
      cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    
    if (obj.score > 0) {
      cell.detailTextLabel.text = [NSString stringWithFormat:@"支出 %@", [Utilities double2string:obj.score]];
    }
    
    if (obj.score < 0) {
      cell.detailTextLabel.text = [NSString stringWithFormat:@"收入 %@", [Utilities double2string:-obj.score]];
    }
  }
  
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  
  if (section == 0) {
    return @"比分情况";
  }
  
  return @"支出收入情况";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  return 44.0f;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  if ([indexPath section] == 0) {
    // 牌局情况
    WLGameHistoryVCTL *vctl = [[WLGameHistoryVCTL alloc] init];
    vctl.showingGameNum = [indexPath row] + 1;
    [self.navigationController pushViewController:vctl animated:YES];
    [vctl release];
  }
}

#pragma mark - 
- (void)reloadTableData {
  
  self.userScoreInOneGameArray = [WLdbGameObj userSummaryForGameID:[WLAppDelegate currentGameID] userID:self.userID isCashOut:NO];
  self.userCashOutHistoryArray = [WLdbGameObj userSummaryForGameID:[WLAppDelegate currentGameID] userID:self.userID isCashOut:YES];
  self.navigationItem.title = self.userName;
  [self.ibTableView reloadData];
}

- (void)next:(id)sender {
  
  NSArray *attendees = [WLAppDelegate currentAttendees];
  self.userIndex++;
  WLdbUserObj *next = [attendees objectAtIndex:self.userIndex % [attendees count]];
  self.userName=next.user_name;
  self.userID = next.user_id;
  [self reloadTableData];
}

@end
