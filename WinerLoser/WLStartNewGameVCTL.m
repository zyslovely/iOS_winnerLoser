//
//  WLAddUserVCTL.m
//  WinerLoser
//
//  Created by Tom on 11/15/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import "WLStartNewGameVCTL.h"
#import "WLAppDelegate.h"
#import "WLGameInfo.h"
#import "WLdbUserObj.h"
#import "WLSummaryTableVCTL.h"
#import "WLAllUsersTableVCTL.h"

#define kAlert_GDY_SCORE      1001

@interface WLStartNewGameVCTL ()
<UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation WLStartNewGameVCTL

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
  
  if (!_maskView) {
    _maskView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, SCREEN_HEIGHT_WITHOUT_STATUS_BAR)];
    [_maskView addTarget:self action:@selector(viewTouched:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_maskView];
    [_maskView setHidden:YES];
  }
  
  if (!_pickDataArray) {
    _pickDataArray = [[NSArray alloc] initWithObjects:@"普通牌局",@"干瞪眼", nil];
  }

  self.navigationItem.title = @"开始新的牌局";

  self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)] autorelease];
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(confirmed:)] autorelease];
  
  self.ibSelectedUserTableView.backgroundView = nil;
  self.ibSelectedUserTableView.backgroundColor = [UIColor whiteColor];
  
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
  
  [self pickerHide];
}




- (void)viewWillAppear:(BOOL)animated {
  
  [super viewWillAppear:animated];
  self.navigationController.navigationBarHidden = NO;
  self.selectedUsers = [WLAppDelegate currentAttendees];
  [self.ibSelectedUserTableView reloadData];
  self.navigationItem.title = [NSString stringWithFormat:@"%d个参加者", [_selectedUsers count]];  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
  

  SAFECHECK_RELEASE(_pickDataArray);
  SAFECHECK_RELEASE(_maskView);
  
  self.ibSelectedUserTableView = nil;
  self.ibUserNameFld = nil;
  
    [self setIbGameTypeBtn:nil];
    [self setIbGameTypePicker:nil];
  [self setIbCardValue:nil];
  [super viewDidUnload];
}

- (void)keyboardWillShow:(id)sender {
  
  
  [self.ibSelectedUserTableView setHidden:YES];
}

- (void)keyboardWillHide:(id)sender {
  
  [self.ibSelectedUserTableView setHidden:NO];
}


- (void)dealloc {
  
  [_selectedUsers release];
  [_maskView release];
  [_pickDataArray release];
  [_ibSelectedUserTableView release];
  [_ibUserNameFld release];
  [_ibGameTypeBtn release];
  [_ibGameTypePicker release];
  [_ibCardValue release];
  [super dealloc];
}

- (IBAction)addBtnPressed:(id)sender {
  
  if (![self.ibUserNameFld.text pd_isNotEmptyString]) {
    return;
  }
  
  WLdbUserObj *user = [[WLdbUserObj alloc] init];
  user.user_name = self.ibUserNameFld.text;
  [user saveToDB];
  [_selectedUsers addObject:user];
  [user release];

  [self.ibSelectedUserTableView reloadData];
  self.ibUserNameFld.text = @"";
  self.navigationItem.title = [NSString stringWithFormat:@"%d个参加者", [_selectedUsers count]];
}

- (IBAction)historyBtnPressed:(id)sender {
  
  WLAllUsersTableVCTL *vctl = [[WLAllUsersTableVCTL alloc] init];
  [self.navigationController pushViewController:vctl animated:YES];
  [vctl release];
}

- (IBAction)viewTouched:(id)sender {
  
  [self.view endEditing:YES];
  [self pickerHide];
}

- (IBAction)gameTypePressed:(id)sender {
  
  [self pickerShow];
}

- (void)cancel:(id)sender {
  
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)confirmed:(id)sender {
  
  
  if ([_selectedUsers count]<2) {
    [Utilities alertWithOK:@"至少要选择2位参加者才能继续"];
    return;
  }
  
  WLGameInfo *info = [[WLAppDelegate sharedDelegate] gameInfo];
  if(info.type == WL_GAME_GAN_DENG_YAN){
    if ([[info.additionalInfoDic objectForKey:kINFO_GDY_CARDVALUE] doubleValue] == 0) {
      [Utilities alertWithOK:@"没有给输家的每张牌设置分数"];
      [self.ibCardValue becomeFirstResponder];
      return;
    }
  }
  
  [[WLAppDelegate sharedDelegate] saveGlobalData];
  
  UINavigationController *navi = [self.navigationController retain];
  WLSummaryTableVCTL *vctl = [[WLSummaryTableVCTL alloc] init];
  [self.navigationController popViewControllerAnimated:NO];
  [navi pushViewController:vctl animated:YES];
  [navi release];
  [vctl release];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // Return the number of rows in the section.
  return [_selectedUsers count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  }
  
  // Configure the cell...
  cell.textLabel.text = [[_selectedUsers objectAtIndex:[indexPath row]] user_name];
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  return 44.0f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  
  return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  if (editingStyle != UITableViewCellEditingStyleDelete) {
    return;
  }
  
  NSUInteger row = [indexPath row];
  
  [_selectedUsers removeObjectAtIndex:row];
  [self.ibSelectedUserTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewCellEditingStyleDelete];
  [self.ibSelectedUserTableView reloadData];
  self.navigationItem.title = [NSString stringWithFormat:@"%d个参加者", [_selectedUsers count]];
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark -
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  if (alertView.cancelButtonIndex == buttonIndex) {
    return;
  }
  
  if (alertView.tag == kAlert_GDY_SCORE) {
    
    WLGameInfo *info = [[WLAppDelegate sharedDelegate] gameInfo];
    [info.additionalInfoDic setObject:[NSNumber numberWithDouble:[self.ibCardValue.text doubleValue]] forKey: kINFO_GDY_CARDVALUE];
    [self.view endEditing:YES];
    [self pickerHide];
  }else {
    // 确认开始
    [self confirmed:nil];
  }
  
}


#pragma mark PickerViewDelegate
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  
  return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return [_pickDataArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
  
  return [_pickDataArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
  
  WLGameInfo *info = [[WLAppDelegate sharedDelegate]gameInfo];
  info.type = row;
  if (info.type == WL_GAME_GAN_DENG_YAN){

    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"干瞪眼的每张剩牌算多少分?" message:@"this is get covered" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
    alert.tag = kAlert_GDY_SCORE;
    UITextField *tf =[[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
    CGAffineTransform transfrom = CGAffineTransformMakeTranslation(0, 30);  //实现对控件位置的控制
    [alert setTransform:transfrom];
    tf.backgroundColor = [UIColor whiteColor];
    tf.text = @"1";
    tf.textAlignment = UITextAlignmentCenter;
    tf.keyboardType = UIKeyboardTypeDecimalPad;
    [tf becomeFirstResponder];
    [alert addSubview:tf];
    self.ibCardValue = tf;
    [tf release];
    
    [alert show];
    [alert release];
  }
  
  [self.ibGameTypeBtn setTitle:[_pickDataArray objectAtIndex:row] forState:UIControlStateNormal];
}

- (void)pickerShow {
  
  [_maskView setHidden:NO];
  [_maskView.superview bringSubviewToFront:_maskView];
  [self.view endEditing:YES];
  
  [UIView animateWithDuration:0.3 animations:^(void){
    
    [self.ibGameTypePicker setHidden:NO];
    [self.ibGameTypePicker.superview bringSubviewToFront:self.ibGameTypePicker];
    
    CGRect frame = [self.ibGameTypePicker frame];
    frame.origin.y = SCREEN_HEIGHT_WITHOUT_STATUS_BAR - frame.size.height - 44.0f;
    [self.ibGameTypePicker setFrame:frame];
  }];
}


- (void)pickerHide {
  
  [UIView animateWithDuration:0.3 animations:^(void){
    
    CGRect frame = [self.ibGameTypePicker frame];
    frame.origin.y = SCREEN_HEIGHT_WITHOUT_STATUS_BAR;
    [self.ibGameTypePicker setFrame:frame];
    
  } completion:^(BOOL finished){
    
    [self.ibGameTypePicker setHidden:YES];
    [_maskView setHidden:YES];
  }];
}
@end
