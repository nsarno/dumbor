//
//  GameScene.m
//  Dumbor
//
//  Created by Arnaud Mesureur on 12/02/14.
//  Copyright (c) 2014 Katana SX. All rights reserved.
//

#import "GameScene.h"
#import "ScoreScene.h"
#import "GameKitHelper.h"

// Collision masks
static uint32_t const kDumborCategory    = 0x1 << 0;
static uint32_t const kPipeCategory      = 0x1 << 1;
static uint32_t const kGroundCategory    = 0x1 << 2;

@interface GameScene ()

@property (nonatomic) SKSpriteNode      *dumbor;
@property (nonatomic) SKSpriteNode      *lastPipe;
@property (nonatomic) SKSpriteNode      *lastPipeScored;
@property (nonatomic) SKLabelNode       *scoreLabel;
@property (nonatomic) NSArray           *pipes;
@property (nonatomic) SKAction          *flapflap;
@property (nonatomic) SKAction          *flapflapflap;
@property (nonatomic) SKAction          *blopSound;
@property (nonatomic) SKAction          *wooshSound;
@property (nonatomic) SKAction          *clangSound;
@property (nonatomic) NSMutableArray    *scrollingItems;
@property (nonatomic) SKShapeNode       *overlayNode;

@end

@implementation GameScene
{
    NSTimeInterval  _lastUpdateTime;
    
    BOOL            _gameOver;
    float           _groundPCT;
    float           _pipeOffsetX;
    float           _pipeOffsetY;
    int             _impulse;
    int             _score;
    int             _scrollingPPS;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        _score = 0;
        _gameOver = NO;
        _groundPCT = 0.15;
        _pipeOffsetX = 175.f;
        _pipeOffsetY = 113.f;
        _impulse = 16.f;
        _scrollingPPS = 155.f;
        
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0, -8);
        CGPathRef worldPath = CGPathCreateWithRect(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height + 50.f), nil);
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromPath:worldPath];
        CGPathRelease(worldPath);

        [self initScrollingBackground];
        [self initPipes];
        
        // Score label
        SKShapeNode *circle = [SKShapeNode node];
        
        CGMutablePathRef scorePath = CGPathCreateMutable();
        CGPathAddArc(scorePath, NULL, 0, 0, 30, 0, M_PI * 2, YES);
        circle.path = scorePath;
        CGPathRelease(scorePath);
        
        circle.fillColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:0.75];
        circle.position = CGPointMake(size.width * .5f, size.height - 50.f - 45.f);
        circle.zPosition = 1000;
        [self addChild:circle];

        self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"04B03"];
        self.scoreLabel.fontColor = [UIColor blackColor];
        self.scoreLabel.position = CGPointMake(0, -10);
        self.scoreLabel.fontSize = 28.f;
        self.scoreLabel.fontColor = [UIColor whiteColor];
        self.scoreLabel.text = @"0";
        [circle addChild:self.scoreLabel];
        
        // Overlay flashing node
        self.overlayNode = [SKShapeNode node];
        self.overlayNode.position = CGPointMake(0, 0);
        self.overlayNode.zPosition = 9999;
        self.overlayNode.path = [UIBezierPath bezierPathWithRect:self.frame].CGPath;
        self.overlayNode.strokeColor = [SKColor colorWithWhite:1 alpha:0];
        self.overlayNode.fillColor = [SKColor colorWithWhite:1 alpha:0];
        [self addChild:self.overlayNode];
        
        // Dumbor
        self.dumbor = [SKSpriteNode spriteNodeWithImageNamed:@"babor_01"];
        self.dumbor.position = CGPointMake(size.width / 3.f, size.height * 0.85);
        self.dumbor.size = CGSizeMake(45, 35);
        self.dumbor.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.dumbor.frame.size.height / 2.f];
        self.dumbor.physicsBody.allowsRotation = NO;
        self.dumbor.physicsBody.affectedByGravity = YES;
        self.dumbor.physicsBody.categoryBitMask = kDumborCategory;
        self.dumbor.physicsBody.contactTestBitMask = kPipeCategory;
        self.dumbor.zPosition = 10000;

        NSArray *textures = @[[SKTexture textureWithImageNamed:@"babor_01"], [SKTexture textureWithImageNamed:@"babor_02"]];
        self.flapflap = [SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:.20 / textures.count]];
        self.flapflapflap = [SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:.15 / textures.count]];
        [self.dumbor runAction:self.flapflap withKey:@"flapflap"];
        
        [self addChild:self.dumbor];
        
        // Sounds
        self.blopSound = [SKAction playSoundFileNamed:@"blop.mp3" waitForCompletion:NO];
        self.wooshSound = [SKAction playSoundFileNamed:@"woosh.mp3" waitForCompletion:NO];
        self.clangSound = [SKAction playSoundFileNamed:@"clang.mp3" waitForCompletion:NO];
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
        ground.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, ground.size.width, ground.size.height)];
        ground.physicsBody.categoryBitMask = kGroundCategory;
        ground.physicsBody.contactTestBitMask = kDumborCategory;
        [self addChild:ground];
    }
    
    [self.scrollingItems addObject:@{ @"name" : @"clouds", @"pps" : @35.f}];
    [self.scrollingItems addObject:@{ @"name" : @"trees", @"pps" : @75.f}];
    [self.scrollingItems addObject:@{ @"name" : @"ground", @"pps" : [NSNumber numberWithInt:_scrollingPPS]}];
}

- (void)initPipes
{
    NSMutableArray *pipes = [NSMutableArray arrayWithCapacity:4];
    for (int i = 0; i < 5; ++i)
    {
        SKSpriteNode *bpipe = [SKSpriteNode spriteNodeWithImageNamed:@"bot-book"];
        bpipe.name = @"pipe";
        bpipe.zPosition = 20;
        bpipe.size = CGSizeMake(65.f, 275.f);
        bpipe.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bpipe.frame.size];
        bpipe.physicsBody.categoryBitMask = kPipeCategory;
        bpipe.physicsBody.contactTestBitMask = kDumborCategory;
        bpipe.physicsBody.dynamic = NO;
        [self addChild:bpipe];
        
        SKSpriteNode *tpipe = [SKSpriteNode spriteNodeWithImageNamed:@"top-book"];
        tpipe.name = @"pipe";
        tpipe.zPosition = 20;
        tpipe.size = CGSizeMake(65.f, 275.f);
        tpipe.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:tpipe.frame.size];
        tpipe.physicsBody.dynamic = NO;
        tpipe.physicsBody.categoryBitMask = kPipeCategory;
        tpipe.physicsBody.contactTestBitMask = kDumborCategory;
        [self addChild:tpipe];
        
        SKSpriteNode *dirt = [SKSpriteNode spriteNodeWithImageNamed:@"dirt"];
        dirt.name = @"dirt";
        dirt.zPosition = 30.f;
        dirt.size = CGSizeMake(100.f, 20.f);
        [bpipe addChild:dirt];

        pipes[i] = [NSMutableArray arrayWithArray:@[bpipe, tpipe]];
        [self generatePipesPosition:pipes[i]];
        self.lastPipe = tpipe;
    }
    self.pipes = [NSArray arrayWithArray:pipes];
    self.lastPipeScored = nil;
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

-(void)update:(CFTimeInterval)currentTime
{
    if (_gameOver == NO)
    {
        NSTimeInterval dt = 0.f;

        if (_lastUpdateTime)
            dt = currentTime - _lastUpdateTime;
        
        [self animateDumbor:dt];
        [self moveScrollingItems:dt];
        [self movePipes:dt];
        
        for (NSArray *pair in self.pipes)
        {
            int x = self.dumbor.position.x;
            SKSpriteNode *pipe = (SKSpriteNode *)pair[0];
            if (pipe != self.lastPipeScored && pipe.position.x - 10.f < x && x < pipe.position.x + 5.f)
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
    else
    {
        if (self.dumbor.position.y <= 0)
        {
            ScoreScene *scoreScene = [[ScoreScene alloc] initWithSize:self.frame.size score:_score snapshot:nil];
            scoreScene.scaleMode = SKSceneScaleModeAspectFill;
            [self.view presentScene:scoreScene];
        }
    }
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

- (void)animateDumbor:(NSTimeInterval)dt
{
    static float    lastY = 0;
    static BOOL     isGoingUp = YES;
    
    if (self.dumbor.position.y < lastY - 2.f && (isGoingUp || lastY == 0))
    {
        isGoingUp = NO;
        [self.dumbor removeActionForKey:@"rotateUp"];
        [self.dumbor runAction:[SKAction rotateToAngle:-M_PI / 4.f duration:.5f] withKey:@"rotateDown"];
        [self.dumbor.physicsBody applyImpulse:CGVectorMake(0, -3.f)];
    }
    if (self.dumbor.position.y >= lastY && (!isGoingUp || lastY == 0))
    {
        isGoingUp = YES;
        [self.dumbor removeActionForKey:@"rotateDown"];
        [self.dumbor runAction:[SKAction rotateToAngle:M_PI / 6.f duration:.25f] withKey:@"rotateUp"];
    }
    lastY = self.dumbor.position.y;
}

- (void)movePipes:(NSTimeInterval)dt
{
    [self enumerateChildNodesWithName:@"pipe" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *pipe = (SKSpriteNode *)node;
        CGPoint groundVelocity = CGPointMake(-_scrollingPPS, 0.f);
        CGPoint amountToMove = CGPointMake(groundVelocity.x * dt, groundVelocity.y * dt);
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
    int             pipeY = arc4random() % (int)(self.frame.size.height * _groundPCT * 1.75) + (self.frame.size.height * _groundPCT * 0.5);
    float           last_pipe_x = self.lastPipe == nil ? self.frame.size.width * 1.5 : self.lastPipe.position.x;
    
    bpipe.position = CGPointMake(last_pipe_x + _pipeOffsetX, pipeY);
    [bpipe enumerateChildNodesWithName:@"dirt" usingBlock:^(SKNode *node, BOOL *stop) {
        node.position = CGPointMake(0.f, self.frame.size.height * _groundPCT - pipeY);
    }];
    tpipe.position = CGPointMake(last_pipe_x + _pipeOffsetX, pipeY + tpipe.size.height + _pipeOffsetY);
    self.lastPipe = bpipe;
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    [self runAction:self.clangSound];
    SKAction *alphaToWhite = [SKAction customActionWithDuration:.1f actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        self.overlayNode.fillColor = [SKColor colorWithWhite:.75f alpha:0.85];
    }];
    SKAction *whiteToAlpha = [SKAction customActionWithDuration:.1f actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        self.overlayNode.fillColor = [SKColor colorWithWhite:.75f alpha:0];
    }];
    [self .overlayNode runAction:[SKAction sequence:@[alphaToWhite, whiteToAlpha, alphaToWhite, whiteToAlpha, alphaToWhite, whiteToAlpha]]];
    if (_gameOver == NO)
    {
        [self gameOver];
    }
}

- (void)gameOver
{
    _gameOver = YES;
    self.physicsBody = nil;
    
    [self enumerateChildNodesWithName:@"ground" usingBlock:^(SKNode *node, BOOL *stop) {
        node.physicsBody = nil;
    }];
    
    [self enumerateChildNodesWithName:@"pipe" usingBlock:^(SKNode *node, BOOL *stop) {
        node.physicsBody = nil;
    }];
    
    [self.dumbor.physicsBody applyImpulse:CGVectorMake(-4, 10)];
    [self.dumbor runAction:[SKAction rotateByAngle:M_PI duration:0.25f]];
    [self.dumbor runAction:self.flapflapflap withKey:@"flapflapflap"];
}

@end
