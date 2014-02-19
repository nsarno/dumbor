//
//  MenuScene.m
//  Dumbor
//
//  Created by Arnaud Mesureur on 18/02/14.
//  Copyright (c) 2014 Katana SX. All rights reserved.
//

#import "MenuScene.h"
#import "GameScene.h"

@implementation MenuScene
{
    NSTimeInterval _lastUpdateTime;
}

- (id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self)
    {
        _lastUpdateTime = 0;

        for (int i = 0; i < 3; ++i)
        {
            SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
            background.name = @"background";
            background.anchorPoint = CGPointZero;
            background.position = CGPointMake(i * size.width, 120.f);
            background.size = CGSizeMake(size.width, size.height);
            [self addChild:background];
        }

        SKSpriteNode *dumbor = [SKSpriteNode spriteNodeWithImageNamed:@"babor_01"];
        dumbor.position = CGPointMake(size.width / 2.f, size.height * 0.85);
        dumbor.size = CGSizeMake(40, 30);
        [self addChild:dumbor];

        NSArray *textures = @[[SKTexture textureWithImageNamed:@"babor_01"], [SKTexture textureWithImageNamed:@"babor_02"]];
        SKAction *flapflap = [SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:.20 / textures.count]];
        [dumbor runAction:flapflap];
        
        SKAction *staticFlight = [SKAction repeatActionForever:[SKAction sequence:@[[SKAction moveBy:CGVectorMake(0.f, 10.f) duration:0.5], [SKAction moveBy:CGVectorMake(0.f, -10.f) duration:0.5]]]];
        [dumbor runAction:staticFlight];

        SKSpriteNode *title = [SKSpriteNode spriteNodeWithImageNamed:@"fappy-babor-green"];
        title.position = CGPointMake(size.width / 2.f, size.height * 0.70);
        title.size = CGSizeMake(245.f, 50.f);
        [self addChild:title];
        
        SKSpriteNode *startButton = [SKSpriteNode spriteNodeWithImageNamed:@"start-button"];
        startButton.anchorPoint = CGPointZero;
        startButton.size = CGSizeMake(100.f, 50.f);
        startButton.position = CGPointMake(size.width / 2.f - startButton.size.width / 2.f, size.height * 0.50);
        startButton.name = @"start-button";
        [self addChild:startButton];

        SKSpriteNode *rateButton = [SKSpriteNode spriteNodeWithImageNamed:@"rate-button"];
        rateButton.anchorPoint = CGPointZero;
        rateButton.size = CGSizeMake(100.f, 50.f);
        rateButton.position = CGPointMake(size.width / 2.f - rateButton.size.width / 2.f, size.height * 0.40);
        rateButton.name = @"rate-button";
        [self addChild:rateButton];

        for (int i = 0; i < 3; ++i)
        {
            SKSpriteNode *ground = [SKSpriteNode spriteNodeWithImageNamed:@"ground"];
            ground.anchorPoint = CGPointZero;
            ground.position = CGPointMake((float)i * self.frame.size.width, 0.f);
            ground.name = @"ground";
            ground.size = CGSizeMake(self.frame.size.width, 120.f);
            [self addChild:ground];
        }

    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"start-button"])
    {
        SKSpriteNode *start = (SKSpriteNode *)node;
        SKAction *changeTexture = [SKAction setTexture:[SKTexture textureWithImageNamed:@"start-button-pressed"]];
        start.size = CGSizeMake(100.f, 40.f);
        [start runAction:changeTexture];
    }
    
    if ([node.name isEqualToString:@"rate-button"])
    {
        SKSpriteNode *rate = (SKSpriteNode *)node;
        SKAction *changeTexture = [SKAction setTexture:[SKTexture textureWithImageNamed:@"rate-button-pressed"]];
        rate.size = CGSizeMake(100.f, 40.f);
        [rate runAction:changeTexture];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self enumerateChildNodesWithName:@"start-button" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *start = (SKSpriteNode *)node;
        SKAction *changeTexture = [SKAction setTexture:[SKTexture textureWithImageNamed:@"start-button"]];
        start.size = CGSizeMake(100.f, 50.f);
        [start runAction:changeTexture];
    }];
    
    [self enumerateChildNodesWithName:@"rate-button" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *rate = (SKSpriteNode *)node;
        SKAction *changeTexture = [SKAction setTexture:[SKTexture textureWithImageNamed:@"rate-button"]];
        rate.size = CGSizeMake(100.f, 50.f);
        [rate runAction:changeTexture];
    }];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self enumerateChildNodesWithName:@"start-button" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *start = (SKSpriteNode *)node;
        SKAction *changeTexture = [SKAction setTexture:[SKTexture textureWithImageNamed:@"start-button"]];
        start.size = CGSizeMake(100.f, 50.f);
        [start runAction:changeTexture];
    }];
    
    [self enumerateChildNodesWithName:@"rate-button" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *rate = (SKSpriteNode *)node;
        SKAction *changeTexture = [SKAction setTexture:[SKTexture textureWithImageNamed:@"rate-button"]];
        rate.size = CGSizeMake(100.f, 50.f);
        [rate runAction:changeTexture];
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"start-button"])
    {
        SKScene *gameScene = [GameScene sceneWithSize:self.view.bounds.size];
        gameScene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:gameScene];
    }
    
    if ([node.name isEqualToString:@"rate-button"])
    {
        // RATE APP
        SKSpriteNode *rate = (SKSpriteNode *)node;
        SKAction *changeTexture = [SKAction setTexture:[SKTexture textureWithImageNamed:@"rate-button"]];
        rate.size = CGSizeMake(100.f, 50.f);
        [rate runAction:changeTexture];
    }
}

-(void)update:(CFTimeInterval)currentTime
{
    NSTimeInterval dt;
    if (_lastUpdateTime)
        dt = currentTime - _lastUpdateTime;
    else
        dt = 0.f;
    
    [self moveBackground:dt];
    [self moveGround:dt];
    
    _lastUpdateTime = currentTime;
}

- (void)moveGround:(NSTimeInterval)dt
{
    [self enumerateChildNodesWithName:@"ground" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *ground = (SKSpriteNode *)node;
        CGPoint groundVelocity = CGPointMake(-150.f, 0.f);
        CGPoint amountToMove = CGPointMake(groundVelocity.x * dt, groundVelocity.y * dt);
        ground.position = CGPointMake(ground.position.x + amountToMove.x, ground.position.y + amountToMove.y);
        if (ground.position.x <= -ground.size.width)
        {
            ground.position = CGPointMake(ground.size.width - 2.f, ground.position.y);
        }
    }];
}

- (void)moveBackground:(NSTimeInterval)dt
{
    [self enumerateChildNodesWithName:@"background" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *background = (SKSpriteNode *)node;
        CGPoint backgroundVelocity = CGPointMake(-50.f, 0.f);
        CGPoint amountToMove = CGPointMake(backgroundVelocity.x * dt, backgroundVelocity.y * dt);
        background.position = CGPointMake(background.position.x + amountToMove.x, background.position.y + amountToMove.y);
        if (background.position.x <= -background.size.width)
        {
            background.position = CGPointMake(self.frame.size.width, background.position.y);
        }
    }];
}


@end
