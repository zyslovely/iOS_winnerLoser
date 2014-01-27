//
//  WLDeleteUserVCTL.m
//  WinerLoser
//
//  Created by eason on 1/27/14.
//  Copyright (c) 2014 Tom. All rights reserved.
//

#import "WLDeleteUserVCTL.h"
#import "WLAppDelegate.h"
#import "WLGameInfo.h"
#import "WLdbUserObj.h"
#import "WLSummaryObj.h"
@interface WLDeleteUserVCTL ()
{
    NSMutableArray *_summaryArray;
}

@end

@implementation WLDeleteUserVCTL

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
    if(!_summaryArray)
    {
        _summaryArray = [[NSMutableArray alloc] init];
    }

    [self generateSummaryArray];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_summaryArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    
    WLSummaryObj *summary = [_summaryArray objectAtIndex:[indexPath row]];
    cell.textLabel.text = summary.userName;
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 10, 140, 20)];
    countLabel.text = [NSString stringWithFormat:@"当前得分:%d",(0-[summary.unPaidString intValue])];
    [cell addSubview:countLabel];
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

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    WLSummaryObj *obj = [_summaryArray objectAtIndex:indexPath.row];
    if (![obj.unPaidString isEqualToString:@"0"])
    {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:nil message:@"亲,请把帐先结了再走" delegate:nil cancelButtonTitle:@"好吧" otherButtonTitles:nil];
        [errorAlert show];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    for (WLdbUserObj *userObj in [WLAppDelegate currentAttendees])
    {
        if (userObj.user_id == obj.userID)
        {
            [[WLAppDelegate currentAttendees] removeObject:userObj];
            break;
        }
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


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
    [_summaryArray addObjectsFromArray:summaryArray];
    [summaryArray release];
    
    if (count == [_summaryArray count]-1) {
        return YES;
    }
    
    return NO;
}

@end
