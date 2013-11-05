//
//  WLHistoryAllVCTL.m
//  WinerLoser
//
//  Created by Tom on 11/17/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import "WLGameHistoryVCTL.h"
#import "WLAppDelegate.h"
#import "WLdbGameObj.h"

@interface WLGameHistoryVCTL ()
<UIAlertViewDelegate>

@end

@implementation WLGameHistoryVCTL

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
  [self showTable];
  
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(delete:)] autorelease];
}

- (void)viewWillAppear:(BOOL)animated {
  
  [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  
  [_gameObjArray release];
  
  [_ibToolbar release];
  [_ibLeftItem release];
  [_ibRightItem release];
  [_ibTableView release];
  [super dealloc];
}


- (void)viewDidUnload {
  
  [self setIbToolbar:nil];
  [self setIbLeftItem:nil];
  [self setIbRightItem:nil];
  [self setIbTableView:nil];
  [super viewDidUnload];
}


#pragma mark -

- (void)showTable {
  
  [self checkToolbarValidation];  
  self.gameObjArray = [WLdbGameObj summaryForGameID:[WLAppDelegate currentGameID] withGameNum:_showingGameNum];
  
  [self.ibTableView reloadData];
  self.navigationItem.title = [NSString stringWithFormat:@"第%d局", _showingGameNum];
}


- (void)checkToolbarValidation {
  
  if (_showingGameNum < [WLAppDelegate currentGameIndex]) {
    [self.ibRightItem setEnabled:YES];
  }else
    [self.ibRightItem setEnabled:NO];
  
  
  if (_showingGameNum >1) {
    [self.ibLeftItem setEnabled:YES];
  }else {
    [self.ibLeftItem setEnabled:NO];
  }
}
- (IBAction)nextGamePressed:(id)sender {
  _showingGameNum++;
  [self showTable];
}

- (IBAction)prevGamePressed:(id)sender {
  _showingGameNum--;
  [self showTable];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // Return the number of rows in the section.
  return [_gameObjArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
  }
  
  // Configure the cell...
  WLdbGameObj *obj = [_gameObjArray objectAtIndex:[indexPath row]];
  cell.textLabel.text = obj.userName;
  if (obj.score > 0) {
    cell.detailTextLabel.textColor = kLoserColor;
  }else {
    cell.detailTextLabel.textColor = kWinnerColor;
  }
  cell.detailTextLabel.text = [Utilities double2string:obj.score];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  return 44.0f;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */


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

#pragma mark - 

- (void)delete:(id)sender {
  
  if ([WLAppDelegate currentGameIndex] == 0) {
    return;
  }
  
  UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"是否删除本局" message:@"该操作无法恢复" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
  [alert show];
  [alert release];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  if(alertView.cancelButtonIndex == buttonIndex)
    return;
  
  
  // 删除
  [WLdbGameObj removeGameForID:[WLAppDelegate currentGameID] forNum:_showingGameNum];
  [Utilities alertInstant:@"信息已经删除" isError:NO];
  [self.navigationController popViewControllerAnimated:YES];
}


@end
