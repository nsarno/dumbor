//
//  GameViewController.h
//  Dumbor
//
//  Copyright (c) 2014 Katana SX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>

@interface GameViewController : UIViewController <ADBannerViewDelegate>

@property (nonatomic) IBOutlet ADBannerView *bannerView;

@end
