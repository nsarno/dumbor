//
//  GameKitHelper.h
//  Dumbor
//
//  Created by Arnaud Mesureur on 26/02/14.
//  Copyright (c) 2014 Katana SX. All rights reserved.
//

@import GameKit;

extern NSString *const PresentAuthenticationViewController;

@interface GameKitHelper : NSObject

@property (nonatomic, readonly) UIViewController *authenticationViewController;
@property (nonatomic, readonly) NSError *lastError; + (instancetype)sharedGameKitHelper;

- (void)authenticateLocalPlayer;
- (void)reportScore:(int64_t)score forLeaderboardID:(NSString*)leaderboardID;
- (void)showGKGameCenterViewController:(UIViewController *)viewController;
@end