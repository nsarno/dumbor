//
//  ScoreScene.m
//  Dumbor
//
//  Created by Arnaud Mesureur on 20/02/14.
//  Copyright (c) 2014 Katana SX. All rights reserved.
//

#import "ScoreScene.h"
#import "MenuScene.h"

@interface ScoreScene ()

@property (nonatomic) NSMutableArray    *scrollingItems;
@property (nonatomic) SKSpriteNode      *okBtn;
@property (nonatomic) SKSpriteNode      *shareBtn;
@property (nonatomic) MenuScene         *menuScene;

@end

@implementation ScoreScene
{
    NSTimeInterval _lastUpdateTime;
}

- (id)initWithSize:(CGSize)size score:(int)score
{
    if (self = [super initWithSize:size])
    {
        [self initScrollingBackground];
        
        // Create title
        SKSpriteNode *title = [SKSpriteNode spriteNodeWithImageNamed:@"logo"];
        title.position = CGPointMake(size.width / 2.f, size.height * 0.60);
        title.size = CGSizeMake(250.f, 120.f);
        title.zPosition = 20;
        [self addChild:title];
        
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
        
        SKSpriteNode *highScore = [SKSpriteNode spriteNodeWithImageNamed:@"highscore"];
        highScore.size = CGSizeMake(size.width / 2.f, highScore.size.height * size.width / 2.f / size.width);
        highScore.position = CGPointMake(size.width / 3.f, size.height * 0.40f);
        [self addChild:highScore];

        // High Score label
        SKShapeNode *hscircle = [SKShapeNode node];
        CGMutablePathRef hsPath = CGPathCreateMutable();
        CGPathAddArc(hsPath, NULL, 0, 0, 25, 0, M_PI * 2, YES);
        hscircle.path = hsPath;
        hscircle.fillColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:0.75];
        hscircle.position = CGPointMake(size.width * .75f, size.height * 0.40f);;
        hscircle.zPosition = 1000;
        [self addChild:hscircle];
        
        NSNumber *highScoreNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"highscore"];
        SKLabelNode *hscoreLabel = [SKLabelNode labelNodeWithFontNamed:@"04B03"];
        hscoreLabel.fontColor = [UIColor blackColor];
        hscoreLabel.position = CGPointMake(0, -10);
        hscoreLabel.fontSize = 28.f;
        hscoreLabel.fontColor = [UIColor whiteColor];
        hscoreLabel.text = highScoreNumber.stringValue;
        [hscircle addChild:hscoreLabel];
        
        SKSpriteNode *newScore = [SKSpriteNode spriteNodeWithImageNamed:@"newscore"];
        newScore.size = CGSizeMake(size.width / 2.f, newScore.size.height * size.width / 2.f / size.width);
        newScore.position = CGPointMake(size.width / 3.f, size.height * 0.30f);
        newScore.zPosition = 1000;
        [self addChild:newScore];
        
        // New Score label
        SKShapeNode *nscircle = [SKShapeNode node];
        CGMutablePathRef nsPath = CGPathCreateMutable();
        CGPathAddArc(nsPath, NULL, 0, 0, 25, 0, M_PI * 2, YES);
        nscircle.path = nsPath;
        nscircle.fillColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:0.75];
        nscircle.position = CGPointMake(size.width * .75f, size.height * 0.30f);;
        nscircle.zPosition = 1000;
        [self addChild:nscircle];
        
        SKLabelNode *nscoreLabel = [SKLabelNode labelNodeWithFontNamed:@"04B03"];
        nscoreLabel.fontColor = [UIColor blackColor];
        nscoreLabel.position = CGPointMake(0, -10);
        nscoreLabel.fontSize = 28.f;
        nscoreLabel.fontColor = [UIColor whiteColor];
        nscoreLabel.text = [NSString stringWithFormat:@"%d", score];
        [nscircle addChild:nscoreLabel];
        
        // OK btn
        self.okBtn = [SKSpriteNode spriteNodeWithImageNamed:@"ok-btn"];
        self.okBtn.size = CGSizeMake(100.f, 50.f);
        self.okBtn.position = CGPointMake(size.width / 2.f, size.height * 0.15);
        self.okBtn.zPosition = 30;
        self.okBtn.name = @"ok-button";
        [self addChild:self.okBtn];
        
        self.menuScene = [MenuScene sceneWithSize:size];
        self.menuScene.scaleMode = SKSceneScaleModeAspectFill;
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
        clouds.position = CGPointMake((float)i * self.frame.size.width, 120.f);
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
        trees.position = CGPointMake((float)i * self.frame.size.width, 119.f);
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
        ground.size = CGSizeMake(self.frame.size.width + 1.f, 120.f);
        ground.zPosition = 22;
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
    
    if ([node.name isEqualToString:@"ok-button"])
    {
        [self.okBtn runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"ok-btn-pressed"]]];
    }
    else if ([node.name isEqualToString:@"share-button"])
    {
        [self.shareBtn runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"share-btn-pressed"]]];
    }

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.okBtn runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"ok-btn"]]];
    [self.shareBtn runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"share-btn"]]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"ok-button"])
    {
        [self.okBtn runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"ok-btn"]]];
        [self.view presentScene:self.menuScene];
    }
    else if ([node.name isEqualToString:@"share-button"])
    {
        [self.shareBtn runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"share-btn"]]];
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
