//
//  MenuScene.m
//  Dumbor
//
//  Created by Arnaud Mesureur on 18/02/14.
//  Copyright (c) 2014 Katana SX. All rights reserved.
//

#import "MenuScene.h"
#import "GameScene.h"
#import "ScoreScene.h"
#import "GameKitHelper.h"

@interface MenuScene ()

@property (nonatomic) NSMutableArray    *scrollingItems;
@property (nonatomic) SKSpriteNode      *startButton;
@property (nonatomic) SKSpriteNode      *scoreButton;
@property (nonatomic) GameScene         *gameScene;

@end

@implementation MenuScene
{
    NSTimeInterval  _lastUpdateTime;
    float           _groundPCT;
}

- (id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self)
    {
        _lastUpdateTime = 0;
        _groundPCT = 0.15;

        [self initScrollingBackground];

        // Create Babor
        SKSpriteNode *dumbor = [SKSpriteNode spriteNodeWithImageNamed:@"babor_02"];
        dumbor.position = CGPointMake(size.width / 2.f, size.height * 0.70);
        dumbor.size = CGSizeMake(dumbor.size.width * 0.75f, dumbor.size.height * 0.75f);
        dumbor.zRotation = M_PI / 10.f;
        dumbor.zPosition = 10.f;
        [self addChild:dumbor];
        
        NSArray *textures = @[[SKTexture textureWithImageNamed:@"babor_01"], [SKTexture textureWithImageNamed:@"babor_02"]];
        SKAction *flapflap = [SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:.35 / textures.count]];
        [dumbor runAction:flapflap];
        
        SKAction *moveUp = [SKAction moveBy:CGVectorMake(0.f, 30.f) duration:0.75];
        moveUp.timingMode = SKActionTimingEaseOut;
        SKAction *moveDown = [SKAction moveBy:CGVectorMake(0.f, -30.f) duration:0.75];
        moveDown.timingMode = SKActionTimingEaseOut;
        SKAction *flightSequence = [SKAction sequence:@[moveUp, moveDown]];
        [dumbor runAction:[SKAction repeatActionForever:flightSequence]];

        // Create title
        SKSpriteNode *title = [SKSpriteNode spriteNodeWithImageNamed:@"logo"];
        title.position = CGPointMake(size.width / 2.f, size.height * 0.60);
        title.size = CGSizeMake(250.f, 120.f);
        title.zPosition = 20.f;
        [self addChild:title];
        
        // Create start button
        self.startButton = [SKSpriteNode spriteNodeWithImageNamed:@"start-btn"];
        self.startButton.size = CGSizeMake(100.f, 50.f);
        self.startButton.position = CGPointMake(size.width / 2.f, size.height * 0.30 + 60.f);
        self.startButton.name = @"start-button";
        self.startButton.zPosition = 20;
        [self addChild:self.startButton];
        
        // Create score button
        self.scoreButton = [SKSpriteNode spriteNodeWithImageNamed:@"score-btn"];
        self.scoreButton.size = CGSizeMake(100.f, 50.f);
        self.scoreButton.position = CGPointMake(size.width / 2.f, size.height * 0.30);
        self.scoreButton.name = @"score-button";
        self.scoreButton.zPosition = 20;
        [self addChild:self.scoreButton];
        
        self.gameScene = [GameScene sceneWithSize:size];
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
        ground.zPosition = 12;
        [self addChild:ground];
    }
    
    [self.scrollingItems addObject:@{ @"name" : @"clouds", @"pps" : @25.f}];
    [self.scrollingItems addObject:@{ @"name" : @"trees", @"pps" : @50.f}];
    [self.scrollingItems addObject:@{ @"name" : @"ground", @"pps" : @130.f}];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"start-button"])
    {
       [self.startButton runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"start-btn-pressed"]]];
    }
    else if ([node.name isEqualToString:@"score-button"])
    {
        [self.scoreButton runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"score-btn-pressed"]]];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.startButton runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"start-btn"]]];
    [self.scoreButton runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"score-btn"]]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"start-button"])
    {
        [self.startButton runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"start-btn"]]];
        [self.view presentScene:self.gameScene];
    }
    else if ([node.name isEqualToString:@"score-button"])
    {
        [self.scoreButton runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"score-btn"]]];
        UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [[GameKitHelper sharedGameKitHelper] showGKGameCenterViewController:vc];
//        ScoreScene *scoreScene = [[ScoreScene alloc] initWithSize:self.frame.size score:0 snapshot:nil];
//        scoreScene.scaleMode = SKSceneScaleModeAspectFill;
//        [self.view presentScene:scoreScene];
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
