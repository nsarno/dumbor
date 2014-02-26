//
//  GameKitHelper.m
//  Dumbor
//
//  Created by Arnaud Mesureur on 26/02/14.
//  Copyright (c) 2014 Katana SX. All rights reserved.
//

#import "GameKitHelper.h"

@interface GameKitHelper() <GKGameCenterControllerDelegate>
@end

NSString *const PresentAuthenticationViewController = @"present_authentication_view_controller";

@implementation GameKitHelper
{
    BOOL _enableGameCenter;
}

+ (instancetype)sharedGameKitHelper
{
    static GameKitHelper    *sharedGameKitHelper;
    static dispatch_once_t  onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedGameKitHelper = [[GameKitHelper alloc] init];
    });
    return sharedGameKitHelper;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _enableGameCenter = YES;
    }
    return self;
}

- (void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        [self setLastError:error];
        if (viewController != nil)
        {
            [self setAuthenticationViewController:viewController];
        }
        else if([GKLocalPlayer localPlayer].isAuthenticated)
        {
            _enableGameCenter = YES;
        }
        else
        {
            _enableGameCenter = NO;
        }
    };
}

- (void)reportScore:(int64_t)score forLeaderboardID:(NSString *)leaderboardID
{
    if (!_enableGameCenter)
    {
        NSLog(@"Local play is not authenticated");
    }
    NSLog(@"Report score");
    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardID];
    scoreReporter.value = score;
    scoreReporter.context = 0;
    NSArray *scores = @[scoreReporter];
    [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
        NSLog(@"error %@", error.description);
        [self setLastError:error];
    }];
}

- (void)showGKGameCenterViewController: (UIViewController *)viewController
{
    GKGameCenterViewController *gameCenterViewController = [[GKGameCenterViewController alloc] init];
    gameCenterViewController.gameCenterDelegate = self;
    gameCenterViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    [viewController presentViewController:gameCenterViewController animated:YES completion:nil];
}

- (void)setAuthenticationViewController: (UIViewController *)authenticationViewController
{
    if (authenticationViewController != nil)
    {
        _authenticationViewController = authenticationViewController;
        [[NSNotificationCenter defaultCenter] postNotificationName:PresentAuthenticationViewController object:self];
    }
}

- (void)setLastError:(NSError *)error
{
    _lastError = [error copy];
    if (_lastError)
    {
        NSLog(@"GameKitHelper ERROR: %@", [[_lastError userInfo] description]);
    }
}
    
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
