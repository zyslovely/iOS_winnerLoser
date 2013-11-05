//
//  WLGDYAddGameScoreVCTL.m
//  WinerLoser
//
//  Created by Tom on 11/25/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import "WLgdyAddGameScoreVCTL.h"
#import "WLGameInfo.h"
#import "WLAppDelegate.h"
#import "Utilities.h"
#import "WLgdyScoreCell.h"
#import "WLgdyScoreObj.h"
#import "WLdbUserObj.h"
#import "WLdbGameObj.h"
#import "WLdbSettings.h"

#define kButtonAlpha      0.3

@interface WLgdyAddGameScoreVCTL ()
<WLgdyScoreCellDelegate>

@end

@implementation WLgdyAddGameScoreVCTL

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
  _factor = 1;
  _doubeBtnIndexSelected = -1;
  
  if(!_scoreArray){
    _scoreArray = [[NSMutableArray alloc] init];
    for (int i=0; i<[[WLAppDelegate currentAttendees] count]; i++) {
      
      WLdbUserObj *user = [[WLAppDelegate currentAttendees] objectAtIndex:i];
      WLgdyScoreObj *obj = [[WLgdyScoreObj alloc] init];
      obj.userName =user.user_name;
      obj.userID = user.user_id;
      [_scoreArray addObject:obj];
      [obj release];
    }
  }
  
  [self updateGameScoreLabel];
  [self setDoubleButtonHighlightWithCount:_doubeBtnIndexSelected];
  
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(save:)] autorelease];
  
  if ([WLAppDelegate currentRoundIndex] > 1) {
    self.navigationItem.title = [NSString stringWithFormat:@"第%d局-回合%d", [WLAppDelegate currentGameIndex]+1, [WLAppDelegate currentRoundIndex]];
  }else {
    self.navigationItem.title = [NSString stringWithFormat:@"第%d局", [WLAppDelegate currentGameIndex]+1];
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doubleBtnPressed:(id)sender {
  
  NSUInteger tag = [(UIButton *)sender tag];
  if(tag == _doubeBtnIndexSelected) {
    _doubeBtnIndexSelected = -1;
    [self setDoubleButtonHighlightWithCount:_doubeBtnIndexSelected];
    _factor = 1;
  }else {
    
    _doubeBtnIndexSelected = tag;
    [self setDoubleButtonHighlightWithCount:_doubeBtnIndexSelected];
    _factor = 0x01 << (tag + 1);
  }
  
  [self updateGameScoreLabel];
  for (int i=0; i<[_scoreArray count]; i++) {
    WLgdyScoreObj *obj = [_scoreArray objectAtIndex:i];
    obj.score = obj.cardsleft * _factor * [[[[[WLAppDelegate sharedDelegate] gameInfo] additionalInfoDic] objectForKey:kINFO_GDY_CARDVALUE] doubleValue];
    if(obj.cardsleft == 5)
      obj.score *= 2;
  }
  [self updateWinnerCell];
  [self.ibTableView reloadData];
}

- (void)dealloc {
  
  [_ibScoreInGameLbl release];
  [_ibDoubleBtnArray release];
  [_ibTableView release];
  [_scoreArray release];
  
  [super dealloc];
}
- (void)viewDidUnload {
  
  SAFECHECK_RELEASE(_scoreArray);
  
  [self setIbScoreInGameLbl:nil];
  [self setIbDoubleBtnArray:nil];
  [self setIbTableView:nil];
  [super viewDidUnload];
}

- (void)setDoubleButtonHighlightWithCount:(NSInteger)count {
  
  for (int i=0;i<[_ibDoubleBtnArray count];i++) {
    
    UIButton *btn = [_ibDoubleBtnArray objectAtIndex:i];
    if (i<=count) {
      [btn setAlpha:1.0];
    }else
      [btn setAlpha:kButtonAlpha];
  }
}

- (void)updateGameScoreLabel {
  
  double value = [[[[[WLAppDelegate sharedDelegate] gameInfo] additionalInfoDic] objectForKey:kINFO_GDY_CARDVALUE] doubleValue];
  self.ibScoreInGameLbl.text = [NSString stringWithFormat:@"本局每张牌 %@ x %d = %@", [Utilities double2string:value], _factor,[Utilities double2string:value*_factor]];
  
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // Return the number of rows in the section.
  return [_scoreArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  WLgdyScoreCell *cell = (WLgdyScoreCell *)[Utilities cellByClassName:@"WLgdyScoreCell" inNib:@"TableViewCell" forTableView:self.ibTableView];
  [cell setCellByScoreObj:[_scoreArray objectAtIndex:[indexPath row]]];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.delegate = self;
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  return [WLgdyScoreCell cellHeight];
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  // Return NO if you do not want the specified item to be editable.
  
  if ([_scoreArray count]>2) {
    return YES;
  }
  
  return NO;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

  if (editingStyle == UITableViewCellEditingStyleDelete) {
    
    // Delete the row from the data source
    [tableView beginUpdates];
    
    [_scoreArray removeObjectAtIndex:[indexPath row]];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [tableView endUpdates];
    
    [self updateWinnerCell];
  }
}


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // Navigation logic may go here. Create and push another view controller.
  /*
   <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
   // ...
   // Pass the selected object to the new view controller.
   [self.navigationController pushViewController:detailViewController animated:YES];
   [detailViewController release];
   */
}

#pragma mark - WLgdyScoreCellDelegate
- (void)gdyScoreCellCardButtonPressed:(WLgdyScoreCell *)cell {
  
  NSIndexPath *indexPath = [self.ibTableView indexPathForCell:cell];
  WLgdyScoreObj *obj = [_scoreArray objectAtIndex:[indexPath row]];

  
  obj.score = obj.cardsleft * _factor * [[[[[WLAppDelegate sharedDelegate] gameInfo] additionalInfoDic] objectForKey:kINFO_GDY_CARDVALUE] doubleValue];
  if(obj.cardsleft == 5)
    obj.score *= 2;
  
  [self.ibTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
  
  [self updateWinnerCell];
}

- (void)updateWinnerCell {
  
  NSUInteger winnerCount = 0;
  NSUInteger winnerIndex = 0;
  double totalLoseValue = 0;
  
  for (int i=0; i<[_scoreArray count]; i++) {
    
    WLgdyScoreObj *obj = [_scoreArray objectAtIndex:i];
    if (obj.isWinner) {
      winnerCount++;
      winnerIndex = i;
    }else {
      totalLoseValue += obj.score;
    }
  }
  
  if (winnerCount == 1){
    WLgdyScoreObj *obj = [_scoreArray objectAtIndex:winnerIndex];
    [obj setScore:-totalLoseValue];
    [self.ibTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:winnerIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
  }
}

- (BOOL)findLoserExceedGapAndRecalcAllScores {
  
  if (![[WLdbSettings defaultSettings] loserGapInOneRound]) {
    return NO;
  }
  
  NSArray *attendees = [WLAppDelegate currentAttendees];
  BOOL find = NO;
  
  for (int i=0;i<[_scoreArray count];i++) {
    
    WLgdyScoreObj *scoreObj = [_scoreArray objectAtIndex:i];
    WLdbUserObj *user = [attendees objectAtIndex:i];
    double summaryInRound = [WLdbGameObj summaryForGameID:[WLAppDelegate currentGameID] userID:user.user_id inRound:[WLAppDelegate currentRoundIndex]];
    if (summaryInRound + scoreObj.score <= [[WLdbSettings defaultSettings] loserGapInOneRound]) {
      // 没有超出限制
      continue;
    }
    find = YES;
    [scoreObj setScore:[[WLdbSettings defaultSettings] loserGapInOneRound]-summaryInRound];
  }
  
  if(find){
    [self updateWinnerCell];
  }
  
  return find;
}

- (void)save:(id)sender {
  
  NSUInteger winnerCount = 0;
  double scoreCheck = 0;
  for (WLgdyScoreObj *obj in _scoreArray) {
    if(obj.isWinner) winnerCount++;
    scoreCheck += obj.score;
  }
  
  if(scoreCheck != 0){
    
    // 分数记录有问题
    [Utilities alertWithOK:@"记录的不对,输家和赢家的分数对不上"];
    return;
  }
  
  if(winnerCount > 1) {
    
    [Utilities alertWithOK:@"多于1个赢家, 无法保存"];
    return;
  }
  
  if (winnerCount == 0) {
    [Utilities alertWithOK:@"没有选择赢家，无法保存"];
    return;
  }
  
  WLdbSettings *defaultSettings = [WLdbSettings defaultSettings];
  
  if ([defaultSettings loserHasGapInOneRound]) {
    BOOL findSomeLoserExceedLimitation = [self findLoserExceedGapAndRecalcAllScores];
    if (findSomeLoserExceedLimitation && [defaultSettings onlyOneWinner]) {
      
      NSString *string = [NSString stringWithFormat:@"发现有人已经超出本回合的输家限额%d，已经自动调整积分", [defaultSettings loserGapInOneRound]];
      [Utilities alertWithOK:string];
      
    }
  }
  
  [WLAppDelegate increaseGameIndex];

  for (WLgdyScoreObj *obj in _scoreArray){
  
    WLdbGameObj *gameObj = [[WLdbGameObj alloc] init];
    gameObj.gameID = [WLAppDelegate currentGameID];
    gameObj.gameIndex = [WLAppDelegate currentGameIndex];
    gameObj.roundIndex = [WLAppDelegate currentRoundIndex];
    gameObj.userID = obj.userID;
    gameObj.userName = obj.userName;
    gameObj.score = obj.score;
    gameObj.isPaymentDone = 0;
    
    [gameObj saveToDB];
    [gameObj release];
  }

  [Utilities alertInstant:@"保存成功" isError:NO];
  [self.navigationController popViewControllerAnimated:YES];
}
@end
