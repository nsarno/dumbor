//
//  GameScene.m
//  Dumbor
//
//  Created by Arnaud Mesureur on 12/02/14.
//  Copyright (c) 2014 Katana SX. All rights reserved.
//

#import "GameScene.h"
#import "MenuScene.h"

// Collision masks
static uint32_t const kDumborCategory    = 0x1 << 0;
static uint32_t const kPipeCategory      = 0x1 << 1;
static uint32_t const kGroundCategory    = 0x1 << 2;

@interface GameScene ()

@property (nonatomic) SKSpriteNode  *dumbor;
@property (nonatomic) SKSpriteNode  *lastPipe;
@property (nonatomic) SKSpriteNode  *lastPipeScored;
@property (nonatomic) SKLabelNode   *scoreLabel;
@property (nonatomic) NSArray       *pipes;
@property (nonatomic) SKAction      *flapflap;
@property (nonatomic) SKAction      *flapflapflap;
@property (nonatomic) SKAction      *blopSound;
@property (nonatomic) SKAction      *wooshSound;
@property (nonatomic) SKAction      *clangSound;

@end

@implementation GameScene
{
    NSTimeInterval  _lastUpdateTime;
    NSTimeInterval  _dt;
    
    BOOL            _gameOver;
    BOOL            _isInHeaven;
    float           _scrollingPPS;
    float           _scrollingParallaxPPS;
    float           _pipeOffsetX;
    float           _pipeOffsetY;
    int             _impulse;
    int             _score;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        _score = 0;
        _gameOver = NO;
        _scrollingPPS = 150.f;
        _scrollingParallaxPPS = _scrollingPPS / 3.f;
        _pipeOffsetX = 185.f;
        _pipeOffsetY = 110.f;
        _impulse = 10.f;
        
        self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Optima-ExtraBlack"];
        self.scoreLabel.position = CGPointMake(size.width / 2.f, size.height * 0.85f);
        self.scoreLabel.text = @"0";
        [self addChild:self.scoreLabel];
        
        self.physicsWorld.contactDelegate = self;
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsWorld.gravity = CGVectorMake(0, -7);
        
        for (int i = 0; i < 3; ++i)
        {
            SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
            background.name = @"background";
            background.anchorPoint = CGPointZero;
            background.position = CGPointMake(i * size.width, 120.f);
            background.size = CGSizeMake(size.width, size.height);
            [self addChild:background];
        }
        
        self.dumbor = [SKSpriteNode spriteNodeWithImageNamed:@"babor_01"];
        self.dumbor.position = CGPointMake(size.width / 2.f, size.height * 0.85);
        self.dumbor.size = CGSizeMake(40, 30);
        self.dumbor.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.dumbor.frame.size.height / 2.f];
        self.dumbor.physicsBody.allowsRotation = NO;
        self.dumbor.physicsBody.affectedByGravity = YES;
        self.dumbor.physicsBody.categoryBitMask = kDumborCategory;
        self.dumbor.physicsBody.contactTestBitMask = kPipeCategory;
        self.dumbor.zPosition = 10000;
        [self addChild:self.dumbor];
        
        
        NSArray *textures = @[[SKTexture textureWithImageNamed:@"babor_01"], [SKTexture textureWithImageNamed:@"babor_02"]];
        self.flapflap = [SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:.20 / textures.count]];
        self.flapflapflap = [SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:.15 / textures.count]];
        [self.dumbor runAction:self.flapflap withKey:@"flapflap"];
        
        for (int i = 0; i < 3; ++i)
        {
            SKSpriteNode *ground = [[SKSpriteNode alloc] initWithImageNamed:@"ground"];
            ground.anchorPoint = CGPointZero;
            ground.position = CGPointMake((float)i * self.frame.size.width, 0.f);
            ground.name = @"ground";
            ground.size = CGSizeMake(self.frame.size.width, 120.f);
            ground.zPosition = 100;
            ground.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, ground.size.width, ground.size.height)];
            ground.physicsBody.categoryBitMask = kGroundCategory;
            ground.physicsBody.friction = 10.f;
            ground.physicsBody.contactTestBitMask = kDumborCategory;
            [self addChild:ground];
        }

        NSMutableArray *pipes = [NSMutableArray arrayWithCapacity:4];
        for (int i = 0; i < 5; ++i)
        {
            NSMutableArray *pair = [NSMutableArray arrayWithCapacity:2];
            SKSpriteNode *bpipe = [[SKSpriteNode alloc] initWithImageNamed:@"green_pipe"];
            bpipe.name = @"pipe";
            bpipe.zPosition = 10;
            bpipe.size = CGSizeMake(60.f, 275.f);
            bpipe.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bpipe.frame.size];
            bpipe.physicsBody.categoryBitMask = kPipeCategory;
            bpipe.physicsBody.contactTestBitMask = kDumborCategory;
            bpipe.physicsBody.dynamic = NO;
            [self addChild:bpipe];
            pair[0] = bpipe;
            
            SKSpriteNode *tpipe = [[SKSpriteNode alloc] initWithImageNamed:@"green_pipe"];
            tpipe.name = @"pipe";
            tpipe.zPosition = 10;
            tpipe.size = CGSizeMake(60.f, 275.f);
            tpipe.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:tpipe.frame.size];
            tpipe.physicsBody.dynamic = NO;
            tpipe.yScale = -1.0;
            tpipe.physicsBody.categoryBitMask = kPipeCategory;
            tpipe.physicsBody.contactTestBitMask = kDumborCategory;
            [self addChild:tpipe];
            pair[1] = tpipe;
            
            [self generatePipesPosition:pair];
            
            pipes[i] = pair;
            self.lastPipe = tpipe;
        }
        self.pipes = [NSArray arrayWithArray:pipes];
        self.lastPipeScored = nil;
        
        self.blopSound = [SKAction playSoundFileNamed:@"blop.mp3" waitForCompletion:NO];
        self.wooshSound = [SKAction playSoundFileNamed:@"woosh.mp3" waitForCompletion:NO];
        self.clangSound = [SKAction playSoundFileNamed:@"clang.mp3" waitForCompletion:NO];
    }
    return self;
}

- (void)gameOver
{
    _gameOver = YES;

    [self enumerateChildNodesWithName:@"ground" usingBlock:^(SKNode *node, BOOL *stop) {
        node.physicsBody = nil;
    }];
    
    self.physicsBody = nil;
    
    [self.dumbor.physicsBody applyImpulse:CGVectorMake(-3, 8)];
    [self.dumbor runAction:[SKAction rotateByAngle:M_PI duration:0.25f]];
    [self.dumbor runAction:self.flapflapflap withKey:@"flapflapflap"];
}

- (void)goToHeaven
{
    SKSpriteNode *deadDumbor = [SKSpriteNode spriteNodeWithImageNamed:@"white_babor_01"];
    deadDumbor.position = CGPointMake(self.frame.size.width / 2.f, self.frame.size.height * 1.5f);
    deadDumbor.size = CGSizeMake(40, 30);
    deadDumbor.zPosition = 10000;
    [self addChild:deadDumbor];
    
    NSArray *textures = @[[SKTexture textureWithImageNamed:@"white_babor_01"], [SKTexture textureWithImageNamed:@"white_babor_02"]];
    SKAction *flapflap = [SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:.40 / textures.count]];
    [deadDumbor runAction:flapflap];
    [deadDumbor runAction:[SKAction moveToY:self.frame.size.height * 0.90f duration:1.f]];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"magic-effect" ofType:@"sks"];
    SKEmitterNode *magicEffect = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    magicEffect.position = CGPointMake(deadDumbor.size.width / 2.f, -85.f);
    [deadDumbor addChild:magicEffect];
    
    SKSpriteNode *board = [SKSpriteNode spriteNodeWithImageNamed:@"score-frame"];
    board.position = CGPointMake(self.frame.size.width / 2.f, self.frame.size.height * 0.5 * 2);
    board.size = CGSizeMake(self.frame.size.width * 0.75f, self.frame.size.width * 0.45f);
    board.zPosition = 100000;
    [self addChild:board];
    
    SKSpriteNode *shareButton = [SKSpriteNode spriteNodeWithImageNamed:@"share-button-pressed"];
    shareButton.zPosition = 100000;
    shareButton.anchorPoint = CGPointZero;
    shareButton.position = CGPointMake(self.frame.size.width * 0.85f - 100.f, self.frame.size.height * 0.5 * 2);
    shareButton.size = CGSizeMake(100.f, 50.f);
    shareButton.name = @"share-button";
    [self addChild:shareButton];
    
    SKSpriteNode *okButton = [SKSpriteNode spriteNodeWithImageNamed:@"ok-button-pressed"];
    okButton.zPosition = 100000;
    okButton.anchorPoint = CGPointZero;
    okButton.position = CGPointMake(self.frame.size.width * 0.15f, self.frame.size.height * 0.5 * 2);
    okButton.size = CGSizeMake(100.f, 50.f);
    okButton.name = @"ok-button";
    [self addChild:okButton];
    
    [board runAction:[SKAction moveToY:self.frame.size.height * 0.5 duration:1.f]];
    [shareButton runAction:[SKAction moveToY:self.frame.size.height * 0.25 duration:1.f]];
    [okButton runAction:[SKAction moveToY:self.frame.size.height * 0.25 duration:1.f]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_gameOver == NO)
    {
        for (UITouch *touch in touches)
        {
            self.dumbor.physicsBody.velocity = CGVectorMake(0, 0);
            [self.dumbor.physicsBody applyImpulse:CGVectorMake(0, _impulse)];
            [self runAction:self.wooshSound];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];

    if (_gameOver)
    {
        if ([node.name isEqualToString:@"ok-button"])
        {
            SKScene *menuScene = [MenuScene sceneWithSize:self.frame.size];
            [self.view presentScene:menuScene];
        }
        
        if ([node.name isEqualToString:@"share-button"])
        {
        }
    }
}

-(void)update:(CFTimeInterval)currentTime
{
    if (_gameOver == NO)
    {
        if (_lastUpdateTime)
            _dt = currentTime - _lastUpdateTime;
        else
            _dt = 0.f;
        
        [self moveBackground];
        [self moveGround];
        [self movePipes];
        
        for (NSArray *pair in self.pipes)
        {
            int x = self.dumbor.position.x;
            SKSpriteNode *pipe = (SKSpriteNode *)pair[0];
            if (pipe != self.lastPipeScored && pipe.position.x - 5.f < x && x < pipe.position.x + 5.f)
            {
                _score += 1;
                self.scoreLabel.text = [NSString stringWithFormat:@"%d", _score];
                [self runAction:self.blopSound];
                self.lastPipeScored = pipe;
                break;
            }
        }
        
        _lastUpdateTime = currentTime;
    }
    else if (_isInHeaven == NO)
    {
        if (self.dumbor.position.y < 0)
        {
            [self goToHeaven];
            _isInHeaven = YES;
        }
    }
}

- (void)moveBackground
{
    [self enumerateChildNodesWithName:@"background" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *background = (SKSpriteNode *)node;
        CGPoint backgroundVelocity = CGPointMake(-_scrollingParallaxPPS, 0.f);
        CGPoint amountToMove = CGPointMake(backgroundVelocity.x * _dt, backgroundVelocity.y * _dt);
        background.position = CGPointMake(background.position.x + amountToMove.x, background.position.y + amountToMove.y);
        if (background.position.x <= -background.size.width)
        {
            background.position = CGPointMake(self.frame.size.width, background.position.y);
        }
    }];
}

- (void)moveGround
{
    [self enumerateChildNodesWithName:@"ground" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *ground = (SKSpriteNode *)node;
        CGPoint groundVelocity = CGPointMake(-_scrollingPPS, 0.f);
        CGPoint amountToMove = CGPointMake(groundVelocity.x * _dt, groundVelocity.y * _dt);
        ground.position = CGPointMake(ground.position.x + amountToMove.x, ground.position.y + amountToMove.y);
        if (ground.position.x <= -ground.size.width)
        {
            ground.position = CGPointMake(self.frame.size.width, ground.position.y);
        }
    }];
}

- (void)movePipes
{
    [self enumerateChildNodesWithName:@"pipe" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *pipe = (SKSpriteNode *)node;
        CGPoint groundVelocity = CGPointMake(-_scrollingPPS, 0.f);
        CGPoint amountToMove = CGPointMake(groundVelocity.x * _dt, groundVelocity.y * _dt);
        pipe.position = CGPointMake(pipe.position.x + amountToMove.x, pipe.position.y);
    }];

    for (NSArray *pair in self.pipes)
    {
        SKSpriteNode *apipe = (SKSpriteNode *)pair[0];
        if (apipe.position.x < -apipe.size.width)
        {
            [self generatePipesPosition:pair];
        }
    }
}

- (void)generatePipesPosition:(NSArray *)pair
{
    SKSpriteNode    *bpipe = (SKSpriteNode *)pair[0];
    SKSpriteNode    *tpipe = (SKSpriteNode *)pair[1];
    int             pipeY = arc4random() % 120 + 75;
    float           last_pipe_x = self.lastPipe == nil ? self.frame.size.width * 1.5 : self.lastPipe.position.x;
    
    bpipe.position = CGPointMake(last_pipe_x + _pipeOffsetX, pipeY);
    tpipe.position = CGPointMake(last_pipe_x + _pipeOffsetX, pipeY + tpipe.size.height + _pipeOffsetY);
    self.lastPipe = bpipe;
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    [self runAction:self.clangSound];
    [self gameOver];
}

@end
