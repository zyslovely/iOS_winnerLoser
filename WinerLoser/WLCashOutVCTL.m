//
//  WLCashOutVCTL.m
//  WinerLoser
//
//  Created by Tom on 11/24/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import "WLCashOutVCTL.h"
#import "WLdbGameObj.h"
#import "WLAppDelegate.h"
#import "WLCashOutCell.h"
#import "WLCashOutObj.h"

@interface WLCashOutVCTL ()
<WLCashOutCellDelegate>

@property (nonatomic, retain) NSIndexPath *selectedIndexPath;

- (WLCashOutObj *)selectedCashOut;
@end

@implementation WLCashOutVCTL

- (WLCashOutObj *)selectedCashOut {
  
  return [_cashOutSummarArray objectAtIndex:[self.selectedIndexPath row]];
}

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
  self.navigationItem.title = @"结帐";
  if (!_cashOutSummarArray) {
    _cashOutSummarArray = [[WLdbGameObj userArrayForCashOutGame:[WLAppDelegate currentGameID]] retain];
  }
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)] autorelease];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_ibTableView release];
    [super dealloc];
}
- (void)viewDidUnload {
  
  SAFECHECK_RELEASE(_cashOutSummarArray);
  [self setIbTableView:nil];
  [super viewDidUnload];
}

- (void)reCalcWinnerActual{
  
  WLCashOutObj *receiver = nil;
  NSUInteger receiverIndex = 0;
  NSUInteger receiverCount = 0;
  double actualPaid = 0;
  
  for (int i=0;i<[_cashOutSummarArray count];i++) {
    
    WLCashOutObj *obj = [_cashOutSummarArray objectAtIndex:i];
    if (!obj.isPayer) {
      receiver = obj;
      receiverIndex = i;
      receiverCount ++;
    }else {
      actualPaid += obj.actualValue;
    }
  }
  
  if (receiverCount == 1) {
    
    receiver.actualValue = actualPaid;
    [self.ibTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:receiverIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
  }
}

- (IBAction)numBtnPressed:(id)sender {
  
  if (!self.selectedIndexPath) {
    return;
  }
  
  [self.ibTableView selectRowAtIndexPath:self.selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
  WLCashOutObj *obj = [self selectedCashOut];
  UIButton *btn = (UIButton *)sender;
  NSUInteger tag = btn.tag;
  WLCashOutCell *cell = (WLCashOutCell*)[self.ibTableView cellForRowAtIndexPath:self.selectedIndexPath];
  
  if (tag < 10) {
    if (obj.actualValue == 0) {
      obj.actualValue = tag;
    }else {
      if ([[cell.ibActualNumLbl.text substringFromIndex:[cell.ibActualNumLbl.text length]-1] isEqualToString:@"."]) {
        obj.actualValue = [[NSString stringWithFormat:@"%@.%d", [Utilities double2string:obj.actualValue],tag] doubleValue];
        [cell setActualText:[NSString stringWithFormat:@"%.1f", obj.actualValue]];
        [self reCalcWinnerActual];        
        return;
        
      }else {
        obj.actualValue = [[NSString stringWithFormat:@"%@%d",cell.ibActualNumLbl.text,tag] doubleValue];
      }
    }
  }
  
  if (tag == 12) {
    // <
    if (obj.actualValue == 0) {
      return;
    }
    
    NSString *str = cell.ibActualNumLbl.text;
    if ([str pd_isNotEmptyString]) {
      str = [str substringToIndex:[str length]-1];
      [cell setActualText:str];
      obj.actualValue = [cell.ibActualNumLbl.text doubleValue];
    }
    [self reCalcWinnerActual];    
    return;
  }
  
  if (tag == 11) {
    // .
    NSString *str = cell.ibActualNumLbl.text;
    if ([str pd_findSubstring:@"."]) {
      return;
    }
    
    [cell setActualText:[[Utilities double2string:obj.actualValue] stringByAppendingString:@"."]];
    [self reCalcWinnerActual];
    return;
  }
  
  if (tag == 50 || tag == 100) {
    obj.actualValue = tag;
  }

  [self.ibTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.selectedIndexPath]
                            withRowAnimation:UITableViewRowAnimationNone];
  [self reCalcWinnerActual];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // Return the number of rows in the section.
  return [_cashOutSummarArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  WLCashOutCell *cell = (WLCashOutCell*)[Utilities cellByClassName:@"WLCashOutCell" inNib:@"TableViewCell"
                                                      forTableView:self.ibTableView];
  cell.delegate = self;
  [cell setCellByCashOutObj:[_cashOutSummarArray objectAtIndex:[indexPath row]]];
  if ([self.selectedIndexPath row] == [indexPath row] && self.selectedIndexPath) {
    [self.ibTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
  }

  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  return [WLCashOutCell cellHeight];
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  self.selectedIndexPath = indexPath;
}

#pragma mark -
- (BOOL)isValidCashOut {
  
  double winnerMoney = 0;
  double loserMoney = 0;
  
  for(int i=0;i<[_cashOutSummarArray count];i++) {
    
    WLCashOutObj *obj = [_cashOutSummarArray objectAtIndex:i];
    if(!obj.isPayer){
      winnerMoney += obj.actualValue;
    }else{
      loserMoney += obj.actualValue;
    }
  }
  
  if (winnerMoney == loserMoney) {
    return YES;
  }else {
    [Utilities alertWithOK:@"对不起，帐貌似不太对"];
    return NO;
  }
}
- (void)save:(id)sender {
  
  // check validation
  if(![self isValidCashOut]){
    return;
  }
  
  [WLAppDelegate increaseCashOutIndex];
  
  for (int i=0; i<[_cashOutSummarArray count]; i++) {
    
    WLCashOutObj *cashObj = [_cashOutSummarArray objectAtIndex:i];
    if (cashObj.actualValue == 0) {
      continue;
    }
    
    WLdbGameObj *gameObj = [[WLdbGameObj alloc] init];
    gameObj.gameID = [WLAppDelegate currentGameID];
    gameObj.userID = cashObj.userID;
    gameObj.userName = cashObj.userName;
    gameObj.gameIndex = -[WLAppDelegate cashOutIndex];
    gameObj.roundIndex = -1;
    gameObj.isPaymentDone = 1;
    gameObj.score = cashObj.isPayer?cashObj.actualValue:-cashObj.actualValue;
    [gameObj saveToDB];
    [gameObj release];
  }
  
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - WLCashOutCellDelegate 
- (void)cashOutCellClearButtonPressed:(WLCashOutCell *)cell {
  
  [self reCalcWinnerActual];
}

- (void)cashOutCellSwitchPayButtonPressed:(WLCashOutCell *)cell {
  
  NSIndexPath *indexPath = [self.ibTableView indexPathForCell:cell];
  WLCashOutObj *obj = [_cashOutSummarArray objectAtIndex:[indexPath row]];
  obj.isPayer = !obj.isPayer;

  [self.ibTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

@end
