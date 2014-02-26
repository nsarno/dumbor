//
//  GameViewController.m
//  Dumbor
//
//  Created by Arnaud Mesureur on 12/02/14.
//  Copyright (c) 2014 Katana SX. All rights reserved.
//

#import "GameViewController.h"
#import "GameKitHelper.h"
#import "MenuScene.h"

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.bannerView.delegate = self;
    self.bannerView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showAuthenticationViewController) name:PresentAuthenticationViewController object:nil];
    [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    if (!skView.scene)
    {        
        skView.showsFPS = NO;
        skView.showsNodeCount = NO;
        
        // Create and configure the scene.
        SKScene *menuScene = [MenuScene sceneWithSize:skView.bounds.size];
        menuScene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:menuScene];
    }
}

- (void)showAuthenticationViewController
{
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    [self presentViewController: gameKitHelper.authenticationViewController animated:YES completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    self.bannerView.hidden = NO;
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    self.bannerView.hidden = YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
