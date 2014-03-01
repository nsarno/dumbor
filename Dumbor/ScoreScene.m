//
//  ScoreScene.m
//  Dumbor
//
//  Created by Arnaud Mesureur on 20/02/14.
//  Copyright (c) 2014 Katana SX. All rights reserved.
//

#import "ScoreScene.h"
#import "MenuScene.h"
#import "GameScene.h"
#import "GameKitHelper.h"

#import <Social/Social.h>

@interface ScoreScene ()

@property (nonatomic) NSMutableArray    *scrollingItems;
@property (nonatomic) SKSpriteNode      *playBtn;
@property (nonatomic) SKSpriteNode      *quitBtn;
@property (nonatomic) SKSpriteNode      *fbBtn;
@property (nonatomic) SKSpriteNode      *twBtn;
@property (nonatomic) SKSpriteNode      *twitterPicto;
@property (nonatomic) GameScene         *gameScene;

@end

@implementation ScoreScene
{
    NSTimeInterval  _lastUpdateTime;
    float           _groundPCT;
    BOOL            _hasUnlockedNewHighScore;
    int             _score;
}

- (id)initWithSize:(CGSize)size score:(int)score snapshot:(UIImage *)snapshot
{
    if (self = [super initWithSize:size])
    {
        _groundPCT = 0.15;
        _score = score;
        
        NSNumber *hs = [[NSUserDefaults standardUserDefaults] objectForKey:@"highscore"];
        if (hs.intValue <= _score)
        {
            _hasUnlockedNewHighScore = YES;
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_score] forKey:@"highscore"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[GameKitHelper sharedGameKitHelper] reportScore:_score forLeaderboardID:@"hs01"];
        }
        else
        {
            _hasUnlockedNewHighScore = NO;
        }

        
        [self initScrollingBackground];
        
        // High Score label
        SKShapeNode *hscircle = [SKShapeNode node];
        
        CGMutablePathRef hsPath = CGPathCreateMutable();
        CGPathAddArc(hsPath, NULL, 0, 0, 50, 0, M_PI * 2, YES);
        hscircle.path = hsPath;
        CGPathRelease(hsPath);
        
        hscircle.fillColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:0.75];
        hscircle.position = CGPointMake(size.width * 0.5f, size.height * 0.75f);;
        hscircle.zPosition = 1000;
        [self addChild:hscircle];
        
        SKSpriteNode *highScore = [SKSpriteNode spriteNodeWithImageNamed:@"highscore"];
        highScore.size = CGSizeMake(highScore.size.width * 0.65, highScore.size.height * 0.65);
        highScore.position = CGPointMake(-40.f, -50.f);
        [hscircle addChild:highScore];
        
        NSNumber *highScoreNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"highscore"];
        SKLabelNode *hscoreLabel = [SKLabelNode labelNodeWithFontNamed:@"04B03"];
        hscoreLabel.fontColor = [UIColor blackColor];
        hscoreLabel.position = CGPointMake(0.f, -10.f);
        hscoreLabel.fontSize = 28.f;
        hscoreLabel.fontColor = [UIColor whiteColor];
        hscoreLabel.text = highScoreNumber.stringValue;
        [hscircle addChild:hscoreLabel];
        
        // New Score label
        SKShapeNode *nscircle = [SKShapeNode node];
        
        CGMutablePathRef nsPath = CGPathCreateMutable();
        CGPathAddArc(nsPath, NULL, 0, 0, 50, 0, M_PI * 2, YES);
        nscircle.path = nsPath;
        CGPathRelease(nsPath);
        
        nscircle.fillColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:0.75];
        nscircle.position = CGPointMake(size.width * .5f, size.height * 0.5f);
        nscircle.zPosition = 1000;
        [self addChild:nscircle];
        
        SKSpriteNode *newScore = [SKSpriteNode spriteNodeWithImageNamed:@"newscore"];
        newScore.size = CGSizeMake(newScore.size.width * 0.6, newScore.size.height * 0.6);
        newScore.position = CGPointMake(0.f, -50.f);
        newScore.zPosition = 1000;
        [nscircle addChild:newScore];
        
        SKLabelNode *nscoreLabel = [SKLabelNode labelNodeWithFontNamed:@"04B03"];
        nscoreLabel.fontColor = [UIColor blackColor];
        nscoreLabel.position = CGPointMake(0, -10);
        nscoreLabel.fontSize = 28.f;
        nscoreLabel.fontColor = [UIColor whiteColor];
        nscoreLabel.text = [NSString stringWithFormat:@"%d", score];
        [nscircle addChild:nscoreLabel];

        // FB btn
        self.fbBtn = [SKSpriteNode spriteNodeWithImageNamed:@"fb-btn"];
        self.fbBtn.size = CGSizeMake(45.f, 45.f);
        self.fbBtn.position = CGPointMake(65, -45);
        self.fbBtn.zPosition = 30;
        self.fbBtn.name = @"fb-button";
        [hscircle addChild:self.fbBtn];

        // TW btn
        self.twBtn = [SKSpriteNode spriteNodeWithImageNamed:@"twitter-btn"];
        self.twBtn.size = CGSizeMake(45.f, 45.f);
        self.twBtn.position = CGPointMake(115, -45);
        self.twBtn.zPosition = 30;
        self.twBtn.name = @"tw-button";
        [hscircle addChild:self.twBtn];

        // quit btn
        self.playBtn = [SKSpriteNode spriteNodeWithImageNamed:@"play-btn"];
        self.playBtn.size = CGSizeMake(100.f, 50.f);
        self.playBtn.position = CGPointMake(size.width * 0.30f, size.height * 0.25);
        self.playBtn.zPosition = 30;
        self.playBtn.name = @"play-button";
        [self addChild:self.playBtn];

        // quit btn
        self.quitBtn = [SKSpriteNode spriteNodeWithImageNamed:@"quit-btn"];
        self.quitBtn.size = CGSizeMake(100.f, 50.f);
        self.quitBtn.position = CGPointMake(size.width * 0.70f, size.height * 0.25);
        self.quitBtn.zPosition = 30;
        self.quitBtn.name = @"quit-button";
        [self addChild:self.quitBtn];
        
        self.twitterPicto = [SKSpriteNode spriteNodeWithImageNamed:@"twitter-at"];
        self.twitterPicto.name = @"twitter-picto";
        self.twitterPicto.position = CGPointMake(size.width / 2.f, size.height * _groundPCT / 2.5f);
        self.twitterPicto.zPosition = 1000;
        self.twitterPicto.size = CGSizeMake(150.f, 40.f);
        [self addChild:self.twitterPicto];
        
        self.gameScene = [GameScene sceneWithSize:self.frame.size];
        self.gameScene.scaleMode = SKSceneScaleModeAspectFill;
    }
    return self;
}

- (void)initScrollingBackground
{
    // Create static sky node
    SKSpriteNode *sky = [SKSpriteNode spriteNodeWithImageNamed:@"sky"];
    sky.position = CGPointMake(self.frame.size.width / 2.f, self.frame.size.height / 2.f);
    sky.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    [self addChild:sky];
    
    // Create scrolling items
    self.scrollingItems = [NSMutableArray arrayWithCapacity:3];
    
    // Create clouds nodes
    for (int i = 0; i < 3; ++i)
    {
        SKSpriteNode *clouds = [SKSpriteNode spriteNodeWithImageNamed:@"clouds"];
        clouds.anchorPoint = CGPointZero;
        clouds.position = CGPointMake((float)i * self.frame.size.width, self.frame.size.height * _groundPCT);
        clouds.name = @"clouds";
        clouds.size = CGSizeMake(self.frame.size.width, 100.f);
        clouds.zPosition = 10;
        [self addChild:clouds];
    }
    
    // Create trees nodes
    for (int i = 0; i < 3; ++i)
    {
        SKSpriteNode *trees = [SKSpriteNode spriteNodeWithImageNamed:@"trees"];
        trees.anchorPoint = CGPointZero;
        trees.position = CGPointMake((float)i * self.frame.size.width, self.frame.size.height * _groundPCT - 1.f);
        trees.name = @"trees";
        trees.size = CGSizeMake(self.frame.size.width + 1.f, 35.f);
        trees.zPosition = 11;
        [self addChild:trees];
    }
    
    // Create ground nodes
    for (int i = 0; i < 3; ++i)
    {
        SKSpriteNode *ground = [SKSpriteNode spriteNodeWithImageNamed:@"ground"];
        ground.anchorPoint = CGPointZero;
        ground.position = CGPointMake((float)i * self.frame.size.width, 0.f);
        ground.name = @"ground";
        ground.size = CGSizeMake(self.frame.size.width + 1.f, self.frame.size.height * _groundPCT);
        ground.zPosition = 22;
        [self addChild:ground];
    }
    
    [self.scrollingItems addObject:@{ @"name" : @"clouds", @"pps" : @35.f}];
    [self.scrollingItems addObject:@{ @"name" : @"trees", @"pps" : @75.f}];
    [self.scrollingItems addObject:@{ @"name" : @"ground", @"pps" : @155.f}];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];

    if ([node.name isEqualToString:@"play-button"])
    {
        [self.playBtn runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"play-btn-pressed"]]];
    }
    else if ([node.name isEqualToString:@"quit-button"])
    {
        [self.quitBtn runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"quit-btn-pressed"]]];
    }
    else if ([node.name isEqualToString:@"fb-button"])
    {
        [self.fbBtn runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"fb-btn-pressed"]]];
    }
    else if ([node.name isEqualToString:@"tw-button"])
    {
        [self.twBtn runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"twitter-btn-pressed"]]];
    }
    else if ([node.name isEqualToString:@"twitter-picto"])
    {
        self.twitterPicto.size = CGSizeMake(self.twitterPicto.size.width * 1.25, self.twitterPicto.size.height * 1.25);
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.playBtn runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"play-btn"]]];
    [self.quitBtn runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"quit-btn"]]];
    [self.fbBtn runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"fb-btn"]]];
    [self.twBtn runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"twitter-btn"]]];
    self.twitterPicto.size = CGSizeMake(150.f, 40.f);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"play-button"])
    {
        [self.playBtn runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"play-btn"]]];
        [self.view presentScene:self.gameScene];
    }
    else if ([node.name isEqualToString:@"quit-button"])
    {
        [self.quitBtn runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"quit-btn"]]];
        MenuScene *menuScene = [MenuScene sceneWithSize:self.frame.size];
        menuScene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:menuScene];
    }
    else if ([node.name isEqualToString:@"fb-button"])
    {
        [self.fbBtn runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"fb-btn"]]];
        SLComposeViewController *composeVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [composeVC setInitialText:[NSString stringWithFormat:NSLocalizedString(@"SHARE_INITIAL_TEXT", nil), _score]];
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:composeVC animated:YES completion:nil];
    }
    else if ([node.name isEqualToString:@"tw-button"])
    {
        [self.twBtn runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"twitter-btn"]]];
        SLComposeViewController *composeVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [composeVC setInitialText:[NSString stringWithFormat:NSLocalizedString(@"SHARE_INITIAL_TEXT", nil), _score]];
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:composeVC animated:YES completion:nil];
    }
    else if ([node.name isEqualToString:@"twitter-picto"])
    {
        self.twitterPicto.size = CGSizeMake(150.f, 40.f);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://screen_name=fapfapbabor"]];
    }
}

- (void)update:(CFTimeInterval)currentTime
{
    NSTimeInterval dt;
    
    if (_lastUpdateTime)
        dt = currentTime - _lastUpdateTime;
    else
        dt = 0.f;
    
    [self moveScrollingItems:dt];
    
    _lastUpdateTime = currentTime;
}

- (void)moveScrollingItems:(NSTimeInterval)dt
{
    for (NSDictionary *item in self.scrollingItems)
    {
        __block SKSpriteNode *firstNode = nil;
        __block SKSpriteNode *lastNode = nil;
        
        [self enumerateChildNodesWithName:item[@"name"] usingBlock:^(SKNode *node, BOOL *stop) {
            SKSpriteNode *sprite = (SKSpriteNode *)node;
            NSNumber *pps = item[@"pps"];
            
            CGPoint velocity = CGPointMake(-pps.floatValue, 0.f);
            CGPoint amountToMove = CGPointMake(velocity.x * dt, velocity.y * dt);
            
            if (lastNode == nil || sprite.position.x > lastNode.position.x)
                lastNode = sprite;
            if (sprite.position.x <= -sprite.size.width)
                firstNode = sprite;
            sprite.position = CGPointMake(sprite.position.x + amountToMove.x, sprite.position.y + amountToMove.y);
        }];
        firstNode.position = CGPointMake(lastNode.position.x + lastNode.frame.size.width - 2.f, firstNode.position.y);
    }
}

@end
