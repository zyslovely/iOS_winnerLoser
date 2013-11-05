//
//  WLSettingsVCTL.m
//  WinerLoser
//
//  Created by Tom on 11/17/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import "WLSettingsVCTL.h"
#import "WLdbUserObj.h"
#import "WLdbGameObj.h"
#import "WLAppDelegate.h"
#import "WLdbSettings.h"
#import "TKSwitchCell.h"

#define kTextFieldCellTag   1002
#define SWITCH_CELL(x)    (TKSwitchCell *)[_switchCellArray objectAtIndex:x]

@interface WLSettingsVCTL ()
<UIAlertViewDelegate, UITextFieldDelegate>

@end

@implementation WLSettingsVCTL

#pragma mark -
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  
  [self.view endEditing:YES];
  return YES;
}

- (void)textFieldEditEnd:(id)sender {
  
  UITextField *textField = (UITextField *)sender;

  WLdbSettings *settings = [WLdbSettings defaultSettings];
  settings.loserGapInOneRound = [[textField text] intValue];
  [settings saveDB];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
  
  [self.navigationController setNavigationBarHidden:NO];
  [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
  if (!_switchCellArray){
    _switchCellArray = [[NSArray alloc] initWithObjects:
                        [[[TKSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"switchcell"] autorelease],
                        [[[TKSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"switchcell"] autorelease],
    nil];
    
    WLdbSettings *settings = [WLdbSettings defaultSettings];
    [[SWITCH_CELL(0) title] setText:@"每局只有一个赢家"];
    [[SWITCH_CELL(0) slider] setOn:settings.onlyOneWinner];
    [SWITCH_CELL(0) setSelectionStyle:UITableViewCellSelectionStyleNone];
    [[SWITCH_CELL(0) slider] addTarget:self action:@selector(slide0ValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [[SWITCH_CELL(1) title] setText:@"每回合输家有限额"];
    [[SWITCH_CELL(1) slider] setOn:settings.loserHasGapInOneRound];
    [SWITCH_CELL(1) setSelectionStyle:UITableViewCellSelectionStyleNone];
    [[SWITCH_CELL(1) slider] addTarget:self action:@selector(slide1ValueChanged:) forControlEvents:UIControlEventValueChanged];
  }
}

- (void)dealloc {
  
  [_switchCellArray release];
  [_ibTableView release];
  [super dealloc];
}

- (void)didReceiveMemoryWarning
{
  SAFECHECK_RELEASE(_switchCellArray);
  [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  if ([[WLdbSettings defaultSettings] loserHasGapInOneRound]) {
    return 4;
  }
  
  return 3;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  
  if ([indexPath row] == 3 ||( ![[WLdbSettings defaultSettings] loserHasGapInOneRound] && [indexPath row]==2)) {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = @"清空所有数据";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
  }
  
  if ([indexPath row]==2 && [[WLdbSettings defaultSettings] loserHasGapInOneRound]) {
    
    static NSString *CellIdentifier = @"TextFieldCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
      
      UITextField *textField = [[UITextField alloc] init];

      CGRect r = CGRectInset(cell.contentView.bounds, 8, 8);
      r.origin.x = 200;
      r.size.width = 80;
      textField.frame = r;
      textField.borderStyle = UITextBorderStyleRoundedRect;
      textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
      textField.enablesReturnKeyAutomatically = YES;
      textField.returnKeyType = UIReturnKeyDone;
      textField.tag = kTextFieldCellTag;
      textField.autocorrectionType = UITextAutocorrectionTypeNo;
      textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
      textField.delegate = self;
      [textField addTarget:self action:@selector(textFieldEditEnd:) forControlEvents:UIControlEventEditingDidEnd];
      [cell.contentView addSubview:textField];
      
      [textField release];
    }
    cell.textLabel.text = @"输家回合内限额是:";
    UITextField *field = (UITextField *)[cell viewWithTag:kTextFieldCellTag];
    field.text = INT2STR([[WLdbSettings defaultSettings] loserGapInOneRound]);
    
    return cell;
  }
  
  return [_switchCellArray objectAtIndex:[indexPath row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  return 44.0f;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  if ([indexPath row] == 3 || ([indexPath row]==2 && ![[WLdbSettings defaultSettings] loserHasGapInOneRound])) {
    // 清空所有数据
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否确认清空所有数据" message:@"该操作将清楚所有数据，包括已经保存的参加者信息。如果只是想删除记录信息，保留参加者信息，可以在首页选择‘重新开始’" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    [alertView release];
  }
}

#pragma mark - 

- (void)slide0ValueChanged:(id)sender {
  
  WLdbSettings *settings = [WLdbSettings defaultSettings];
  UISwitch *slider = (UISwitch *)sender;
  settings.onlyOneWinner = slider.on;
  [settings saveDB];
}

- (void)slide1ValueChanged:(id)sender {
  
  WLdbSettings *settings = [WLdbSettings defaultSettings];
  UISwitch *slider = (UISwitch *)sender;
  settings.loserHasGapInOneRound = slider.on;
  [settings saveDB];
  
  [self.ibTableView reloadData];
}


#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  if (alertView.cancelButtonIndex == buttonIndex) {
    return;
  }
  
  [WLdbGameObj removeAll];
  [WLdbUserObj removeAll];
  
  [[WLAppDelegate sharedDelegate] gameRestart];
  [Utilities alertInstant:@"用户数据和记录数据已经全部清除" isError:NO];
}

- (void)viewDidUnload {
  [self setIbTableView:nil];
  [super viewDidUnload];
}
@end
