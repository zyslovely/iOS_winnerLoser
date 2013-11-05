//
//  WLAppDelegate.m
//  WinerLoser
//
//  Created by Tom on 11/15/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import "WLAppDelegate.h"

#import "WLViewController.h"
#import "Utilities.h"
#import "WLSettingsVCTL.h"
#import "WLGameInfo.h"

#define kAttendees    @"Attendees"
#define kGameID       @"gameID"
#define kGameIndex    @"gameIndex"
#define kRoundIndex   @"roundIndex"


#define kAlertAppStoreReview      505

#define kAppStoreID         @"581821703"
#define kUDF_deviceToken		@"UDF_deviceToken"
#define kUDF_firstRun       @"UDF_dateOfFirstRun"
#define kUDF_reviewAsked    @"UDF_reviewAsked"

@implementation WLAppDelegate

#pragma mark - Private
-(void) checkReview{
  
	/* ask user to review in app store */
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if (! [defaults objectForKey:kUDF_firstRun]) {
		[defaults setObject:[NSDate date] forKey:kUDF_firstRun];
	}
	
	NSInteger daysSinceInstall = [[NSDate date] timeIntervalSinceDate:[defaults objectForKey:kUDF_firstRun]] / 86400;
	if ((daysSinceInstall >= 3 && [defaults boolForKey:kUDF_reviewAsked] == NO))
	{
		
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"喜欢这个小应用么？",@"Review Title")
                                                        message: NSLocalizedString(@"请在软件商店上给我们的软件打5分评价吧",@"Review Message")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"不去了",@"Review Cancel")
                                              otherButtonTitles:NSLocalizedString(@"这就去",@"Review OK"),nil];
		alertView.tag = kAlertAppStoreReview;
		[alertView show];
		[alertView release];
		
		[defaults setBool:YES forKey:kUDF_reviewAsked];
	}
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - alertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if(alertView.tag == kAlertAppStoreReview ) {
		
		// 给app store 打评价
		if (buttonIndex == 1) {
      
			NSURL *url = [NSURL URLWithString:
                    [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", kAppStoreID]];
			[[UIApplication sharedApplication] openURL:url];
		}
	}
}

- (void)dealloc
{
  [_window release];
  [_viewController release];
  
  [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [self initGlobalData];
  [self checkReview];
  
  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.

  WLViewController* vctl = [[WLViewController alloc] initWithNibName:@"WLViewController" bundle:nil];
  
  UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vctl];
  [vctl release];
  
  self.viewController = navi;
  [navi release];
  
  self.window.rootViewController = self.viewController;
  [self.window makeKeyAndVisible];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  [self saveGlobalData];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  [self saveGlobalData];
}


#pragma mark - 

- (void)initGlobalData {
  
  NSData *data = [[NSMutableData alloc] initWithContentsOfFile:[Utilities fileName2docFilePath:@"global.data"]];
  
  if (data) {
    
    NSKeyedUnarchiver *un = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    self.gameInfo = [un decodeObjectForKey:@"globalData"];
    [un finishDecoding];
    [un release];
    
  }
  
  if (!self.gameInfo) {
    
    WLGameInfo *aGameInfo = [[WLGameInfo alloc] init];
    self.gameInfo = aGameInfo;
    [aGameInfo release];
  }
	[data release];
}

- (void)saveGlobalData {
  
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *ar = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[ar encodeObject:self.gameInfo forKey:@"globalData"];
	[ar finishEncoding];
	
	[data writeToFile:[Utilities fileName2docFilePath:@"global.data"] atomically:YES];
	[ar release];
	[data release];
}


+ (WLAppDelegate *)sharedDelegate {
  
  return (WLAppDelegate *)[[UIApplication sharedApplication] delegate];
  
}

+ (NSString *)currentGameID {
  
  return [[[self sharedDelegate] gameInfo] gameID];
}


+ (NSMutableArray *)currentAttendees {
  
  return [[[self sharedDelegate] gameInfo] attendees];
}

+ (NSUInteger)currentGameIndex {
  
  return [[[self sharedDelegate] gameInfo] gameIndex];
}

+ (NSUInteger)currentRoundIndex {

  
  return [[[self sharedDelegate] gameInfo] roundIndex];
}

+ (void)increaseRoundIndex {

  WLGameInfo *gameInfo = [[self sharedDelegate] gameInfo];
  gameInfo.roundIndex++;
  [[self sharedDelegate]saveGlobalData];
}

+ (void)increaseGameIndex {
  
  WLGameInfo *gameInfo = [[self sharedDelegate] gameInfo];
  gameInfo.gameIndex++;
  [[self sharedDelegate]saveGlobalData];
}

+ (void)decreaseGameIndex {
  
  WLGameInfo *gameInfo = [[self sharedDelegate] gameInfo];
  if (gameInfo.gameIndex == 0) {
    return;
  }
  gameInfo.gameIndex--;
  [[self sharedDelegate]saveGlobalData];
}

+ (NSUInteger)cashOutIndex {
  
  return [[[self sharedDelegate] gameInfo] cashOutIndex];
}

+ (void)increaseCashOutIndex {
  
  WLGameInfo *gameInfo = [[self sharedDelegate] gameInfo];
  gameInfo.cashOutIndex++;
  [[self sharedDelegate]saveGlobalData];
}

- (void)gameRestart {

  [self.gameInfo cleanInfoAndRestart];
  [self saveGlobalData];
}
@end
