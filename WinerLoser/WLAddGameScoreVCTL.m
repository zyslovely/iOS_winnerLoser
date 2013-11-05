//
//  WLOneGameVCTL.m
//  WinerLoser
//
//  Created by Tom on 11/16/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import "WLAddGameScoreVCTL.h"
#import "WLAppDelegate.h"
#import "WLdbUserObj.h"
#import "WLdbGameObj.h"
#import "WLdbSettings.h"


#define kAlertTagEmptyValueFound    1002
@interface WLAddGameScoreVCTL ()
<UIAlertViewDelegate>

@property (nonatomic, retain)  NSIndexPath         *winnerIndexPath;
@property (nonatomic, retain)  NSIndexPath         *selectedIndexPath;

@end

@implementation WLAddGameScoreVCTL

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
  
  if(!_scoreArray){
    
    _scoreArray = [[NSMutableArray alloc] init];
  }
  
  NSArray *all = [WLAppDelegate currentAttendees];
  for (int i=0; i<[all count]; i++) {
    WLdbUserObj *user = [all objectAtIndex:i];
    
    WLScoreObj *obj = [[WLScoreObj alloc] init];
    obj.userName = user.user_name;
    obj.userID = user.user_id;
    
    if ([[WLdbSettings defaultSettings] onlyOneWinner]) {
      
      if (i== [all count]-1) {
        obj.isWinner = YES;
        self.winnerIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
      }
      
    }
    
    [_scoreArray addObject:obj];
    [obj release];
  }
  
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(save:)] autorelease];
  if ([WLAppDelegate currentRoundIndex] > 1) {
    self.navigationItem.title = [NSString stringWithFormat:@"第%d局-回合%d", [WLAppDelegate currentGameIndex]+1, [WLAppDelegate currentRoundIndex]];
  }else {
    self.navigationItem.title = [NSString stringWithFormat:@"第%d局", [WLAppDelegate currentGameIndex]+1];
  }
  
  if ([_scoreArray count]>0) {
    
    self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    WLScoreObj *score = [_scoreArray objectAtIndex:0];
    score.selected = YES;
    
    [self.ibTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)hasEmptyValue {
  
  for (WLScoreObj *obj in _scoreArray) {
    if (obj.score == 0) {
      return YES;
    }
  }
  
  return NO;
}

- (void)save:(id)sender {
  
  if (!_winnerIndexPath) {
    [Utilities alertWithOK:@"没有设置赢家"];
    return;
  }
  
  double scoreCheck = 0;
  NSInteger winnerCount = 0;
  for (WLScoreObj *obj in _scoreArray) {
    scoreCheck += obj.score;
    if (obj.isWinner) {
      winnerCount++;
    }
  }
  
  if(scoreCheck != 0){
    
    // 分数记录有问题
    [Utilities alertWithOK:@"记录的不对,输家和赢家的分数对不上"];
    return;
  }
  
  if ([self hasEmptyValue] && sender != nil) {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"发现有人没有分数" message:@"是否继续" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
    alertView.tag = kAlertTagEmptyValueFound;
    [alertView show];
    [alertView release];
    return;
  }
  
  
  WLdbSettings *defaultSettings = [WLdbSettings defaultSettings];
  
  if ([defaultSettings loserHasGapInOneRound]) {
    
    BOOL findSomeLoserExceedLimitation = [self findLoserExceedGapAndRecalcAllScores];
    if (findSomeLoserExceedLimitation && ([defaultSettings onlyOneWinner] || winnerCount == 1)) {
      
      NSString *string = [NSString stringWithFormat:@"发现有人已经超出本回合的输家限额%d，已经自动调整积分", [defaultSettings loserGapInOneRound]];
      [Utilities alertWithOK:string];
      
    }else if(findSomeLoserExceedLimitation){
      
      NSString *string = [NSString stringWithFormat:@"发现有人已经超出本回合的输家限额%d，请手动调整赢家积分", [defaultSettings loserGapInOneRound]];
      [Utilities alertWithOK:string];
      return;
    }
  }
  
  [WLAppDelegate increaseGameIndex];
  for (int i=0;i<[_scoreArray count];i++) {
    
    WLScoreObj *scoreObj = [_scoreArray objectAtIndex:i];
    WLdbGameObj *gameObj = [[WLdbGameObj alloc] init];
    gameObj.gameID = [WLAppDelegate currentGameID];
    gameObj.gameIndex = [WLAppDelegate currentGameIndex];
    gameObj.roundIndex = [WLAppDelegate currentRoundIndex];
    gameObj.userID = scoreObj.userID;
    gameObj.userName = scoreObj.userName;
    gameObj.score = scoreObj.score;
    [gameObj saveToDB];
    
    [gameObj release];
  }
 
  [self.navigationController popViewControllerAnimated:YES];
}


- (BOOL)hasPointInScoreObj:(WLScoreObj *)obj {
  
  NSString *str = obj.scoreString;
  
  if ([str pd_findSubstring:@"."]){
    return YES;
  }
  
  return NO;
}


- (IBAction)keyBtnPressed:(id)sender {
  
  if(!_selectedIndexPath){
    return;
  }
  
  WLScoreObj *scoreObj = [_scoreArray objectAtIndex:[_selectedIndexPath row]];
  
  UIButton *btn = (UIButton *)sender;
  if (btn.tag < 10) {
    
    // 0 - 9
    
    if (![scoreObj.scoreString pd_isNotEmptyString]) {
      
      if (scoreObj.isWinner)
        [scoreObj resetScoreString:-btn.tag];
      else
        [scoreObj resetScoreString:btn.tag];
      
    }else if([scoreObj.scoreString isEqualToString:@"0"]){
     
      [scoreObj resetScoreString:btn.tag];
      
    }else if ([scoreObj.scoreString isEqualToString:@"-0"]) {
      [scoreObj resetScoreString:-btn.tag];
    }else {
    
      scoreObj.scoreString = [scoreObj.scoreString stringByAppendingString:INT2STR(btn.tag)];
      scoreObj.score = [scoreObj.scoreString doubleValue];
    }
    
  }else if(btn.tag == 10){
    
    // -
    if (![scoreObj.scoreString pd_isNotEmptyString]) {
      
      scoreObj.scoreString = @"-";
      scoreObj.score = 0;
      return;
    }
    
    [scoreObj resetScoreString:-scoreObj.score];
    
  }else if(btn.tag == 11) {
    
    // .
    
    if (![scoreObj.scoreString pd_isNotEmptyString]) {
      scoreObj.scoreString = @"0.";
      return;
    }
    
    if ([scoreObj.scoreString pd_findSubstring:@"."]) {
      return;
    }
    
    scoreObj.scoreString = [scoreObj.scoreString stringByAppendingString:@"."];
  }else if(btn.tag == 12) {
    
    // 后退
    if (![scoreObj.scoreString pd_isNotEmptyString]) {
      return;
    }
    
    scoreObj.scoreString = [scoreObj.scoreString substringToIndex:[scoreObj.scoreString length]-1];
    scoreObj.score = [scoreObj.scoreString doubleValue];
  }
  
  [self.ibTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
  [self findWinnerView];  
  [self reCalcWinnerScores];
}

- (void)dealloc {
  
  [_scoreArray release];
  [_ibTableView release];
  
  [super dealloc];
}

- (void)viewDidUnload {
  
  SAFECHECK_RELEASE(_scoreArray);
  [self setIbTableView:nil];
  
  [super viewDidUnload];
}

- (void)findWinnerView {
  
  NSUInteger hasValue = 0;
  NSInteger indexWithoutValue = -1;
  WLScoreObj *winnerObj = nil;
  
  for (int i=0;i<[_scoreArray count];i++) {
    
    WLScoreObj *scoreObj = [_scoreArray objectAtIndex:i];
    if (scoreObj.score != 0 ) {
      hasValue++;
    }else {
      indexWithoutValue = i;
      winnerObj = scoreObj;
    }
  }
  
  if ([_scoreArray count] <= 1) {
    return;
  }
  
  if (hasValue == [_scoreArray count]-1) {
    
    if (_winnerIndexPath == nil) {
      self.winnerIndexPath = [NSIndexPath indexPathForRow:indexWithoutValue inSection:0];
      winnerObj.isWinner = YES;
    }
  }
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
 
  
  WLScoreCell *cell = (WLScoreCell *)[Utilities cellByClassName:@"WLScoreCell" inNib:@"TableViewCell" forTableView:self.ibTableView];
  cell.delegate = self;
  [cell setCellByScoreObj:[_scoreArray objectAtIndex:[indexPath row]]];

  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  return [WLScoreCell cellHeight];
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if ([_scoreArray count]>2) {
    return YES;
  }
  
  return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

  if (editingStyle == UITableViewCellEditingStyleDelete) {
    
    // Delete the row from the data source
    
    if ([self.selectedIndexPath row] == [indexPath row]) {
      self.selectedIndexPath = nil;
    }else if([self.selectedIndexPath row] > [indexPath row]){
      self.selectedIndexPath = [NSIndexPath indexPathForRow:[self.selectedIndexPath row]-1 inSection:0];
    }
    
    if([self.winnerIndexPath row] == [indexPath row]){
      self.winnerIndexPath = nil;
    }else if([self.winnerIndexPath row] > [indexPath row]){
      self.winnerIndexPath = [NSIndexPath indexPathForRow:[self.winnerIndexPath row]-1 inSection:0];
    }
    
    [self.ibTableView beginUpdates];
    [_scoreArray removeObjectAtIndex:[indexPath row]];    
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.ibTableView endUpdates];
    
    [self findWinnerView];
    [self reCalcWinnerScores];
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
  
  if (self.selectedIndexPath && [self.selectedIndexPath row] == [indexPath row]) {
    return;
  }
  
  for (int i=0; i<[_scoreArray count]; i++) {
    WLScoreObj *score = [_scoreArray objectAtIndex:i];
    if (i == [indexPath row]){
      score.selected = YES;
    }else {
      score.selected = NO;
    }
  }

  [self.ibTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,self.selectedIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
  
  self.selectedIndexPath = indexPath;
}


- (void)reCalcWinnerScores {
  
  NSUInteger winnerCount = 0;
  for (WLScoreObj *score in _scoreArray) {
    if (score.isWinner) {
      winnerCount++;
    }
  }
  
  if (winnerCount > 1) {
    return;
  }
  
  if (!_winnerIndexPath) {
    return;
  }
  
  // 计算其他的得分
  double totalScore = 0;
  for (WLScoreObj *scoreObj in _scoreArray) {
    
    if (!scoreObj.isWinner) {
      totalScore += scoreObj.score;
    }
  }
  
  WLScoreObj *winner = [_scoreArray objectAtIndex:[_winnerIndexPath row]];
  [winner resetScoreString:-totalScore];
  [self.ibTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_winnerIndexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (BOOL)findLoserExceedGapAndRecalcAllScores {
  
  if (![[WLdbSettings defaultSettings] loserGapInOneRound]) {
    return NO;
  }
  
  BOOL find = NO;
  for (int i=0;i<[_scoreArray count];i++) {
    WLScoreObj *scoreObj = [_scoreArray objectAtIndex:i];
    double summaryInRound = [WLdbGameObj summaryForGameID:[WLAppDelegate currentGameID] userID:scoreObj.userID inRound:[WLAppDelegate currentRoundIndex]];
    if (summaryInRound + scoreObj.score <= [[WLdbSettings defaultSettings] loserGapInOneRound]) {
      // 没有超出限制
      continue;
    }
    find = YES;
    [scoreObj resetScoreString:[[WLdbSettings defaultSettings] loserGapInOneRound]-summaryInRound];
  }
  
  if(find){
    [self reCalcWinnerScores];
  }
  
  return find;
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
  
  if (alertView.cancelButtonIndex == buttonIndex) {
    return;
  }
  
  if (alertView.tag == kAlertTagEmptyValueFound) {
    
    [self save:nil];
  }
}

#pragma mark - WLScoreDelegate
- (void)scoreCellWinnerButtonPressed:(WLScoreCell *)cell {
  
  NSIndexPath *indexPath = [self.ibTableView indexPathForCell:cell];
  WLScoreObj *obj = [_scoreArray objectAtIndex:[indexPath row]];
  if(obj.isWinner){
    
    // 从winner变成loser
    [obj resetScoreString:0];
    obj.isWinner = NO;
    self.winnerIndexPath = nil;

    for (int i=0;i<[_scoreArray count];i++) {
      WLScoreObj *score = [_scoreArray objectAtIndex:i];
      if (score.isWinner) {
        self.winnerIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
      }
    }
    
    [self.ibTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
  }else {
    
    // 从loser 变成 winner
    if ([[WLdbSettings defaultSettings] onlyOneWinner]) {
      
      if (_winnerIndexPath) {
        
        WLScoreObj *oldWinner = [_scoreArray objectAtIndex:[_winnerIndexPath row]];
        oldWinner.isWinner = NO;
        [oldWinner resetScoreString:0];
      }

    }
    obj.isWinner = YES;
    self.winnerIndexPath = indexPath;
    
    [self reCalcWinnerScores];
    [self.ibTableView reloadData];
  }
}
@end
