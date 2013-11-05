//
//  WLAppDelegate.h
//  WinerLoser
//
//  Created by Tom on 11/15/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kWinnerColor      [UIColor blueColor]
#define kLoserColor       [UIColor redColor]

@class WLViewController;
@class WLGameInfo;

@interface WLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow                *window;
@property (strong, nonatomic) UINavigationController  *viewController;
@property (nonatomic, retain) WLGameInfo              *gameInfo;

+ (NSMutableArray *)currentAttendees;

+ (NSString *)currentGameID;

+ (NSUInteger)currentGameIndex;
+ (void)increaseGameIndex;
+ (void)decreaseGameIndex;

+ (NSUInteger)currentRoundIndex;
+ (void)increaseRoundIndex;

+ (NSUInteger)cashOutIndex;
+ (void)increaseCashOutIndex;


+ (WLAppDelegate *)sharedDelegate;

- (void)gameRestart;
- (void)saveGlobalData;

@end
