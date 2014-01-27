//
//  WLAllUsersTableViewController.m
//  WinerLoser
//
//  Created by Tom on 11/15/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import "WLAllUsersTableVCTL.h"
#import "WLdbUserObj.h"
#import "WLAppDelegate.h"
#import "WLSummaryObj.h"
@interface WLAllUsersTableVCTL ()
{

}

@end

@implementation WLAllUsersTableVCTL


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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(confirmed:)] autorelease];
  
  if (!_userArray) {
    _userArray = [[NSArray alloc] initWithArray:[WLdbUserObj arrayWithAllUsers]];
  }
  
  if (!_selectionArray) {
    
    _selectionArray = [[NSMutableArray alloc] initWithCapacity:[_userArray count]];
    
    NSMutableArray *currentAttendees = [WLAppDelegate currentAttendees];
    for (int i=0; i<[_userArray count]; i++) {
      
      WLdbUserObj *existUser = [_userArray objectAtIndex:i];
      BOOL exist = NO;
      for(int j=0;j<[currentAttendees count];j++) {
        
        WLdbUserObj *attendee = [currentAttendees objectAtIndex:j];
        if (existUser.user_id == attendee.user_id) {
          exist = YES;
          break;
        }
      }
      
      [_selectionArray addObject:exist?INT2NUM(1):INT2NUM(0)];
    }
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
  SAFECHECK_RELEASE(_userArray);
  SAFECHECK_RELEASE(_selectionArray);

}

- (void)dealloc {
  
  [_userArray release];
  [_selectionArray release];

  
  [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
  return [_userArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  }
  
  // Configure the cell...
  cell.textLabel.text = [[_userArray objectAtIndex:[indexPath row]] user_name];
  
  if ([[_selectionArray objectAtIndex:[indexPath row]] intValue] == 1) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  }else {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }

  return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSUInteger selected = [[_selectionArray objectAtIndex:[indexPath row]] intValue];
    
  [_selectionArray replaceObjectAtIndex:[indexPath row] withObject:INT2NUM(1-selected)];
  [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - 
- (void)confirmed:(id)sender {
  

  NSMutableArray *attendees = [WLAppDelegate currentAttendees];
  [attendees removeAllObjects];
  
  for (int i=0; i<[_selectionArray count]; i++) {
    BOOL selected = [[_selectionArray objectAtIndex:i] intValue] == 1;
    if (selected) {
      [attendees addObject:[_userArray objectAtIndex:i]];
    }
  }
    
  [[WLAppDelegate sharedDelegate] saveGlobalData];
  [self.navigationController popViewControllerAnimated:YES];
}

@end
