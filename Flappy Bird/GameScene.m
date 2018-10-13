//
//  GameScene.m
//  Flappy Bird
//
//  Created by enli on 2018/10/12.
//  Copyright © 2018年 enli. All rights reserved.
//

#import "GameScene.h"

typedef enum {
    idle,
    running,
    over
} GameStatusType;

@implementation GameScene {
    SKSpriteNode *floor1,*floor2,*bird;
    GameStatusType gameStatus;
    UInt32 birdCategory,pipeCategory,floorCategory;
    SKLabelNode *_gameoverLabel,*metersLabel;
    NSUInteger meter;
}

- (void)didMoveToView:(SKView *)view {
    self.backgroundColor = [UIColor colorWithRed:80.0/255.0 green:192.0/255.0 blue:203.0/255.0 alpha:1.0];
    gameStatus = idle;
    birdCategory = 0x1 << 0;
    pipeCategory = 0x1 << 1;
    floorCategory = 0x1 << 2;

    floor1 = [SKSpriteNode spriteNodeWithImageNamed:@"land"];
    floor1.anchorPoint = CGPointMake(0, 0);
    floor1.position = CGPointMake(0, 0);
    floor1.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, floor1.size.width, floor1.size.height)];
    floor1.physicsBody.categoryBitMask =floorCategory;
    [self addChild:floor1];
    floor2 = [SKSpriteNode spriteNodeWithImageNamed:@"land"];
    floor2.anchorPoint = CGPointMake(0, 0);
    floor2.position = CGPointMake(floor1.size.width, 0);
    floor2.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, floor2.size.width, floor2.size.height)];
    floor2.physicsBody.categoryBitMask =floorCategory;
    [self addChild:floor2];
    
    bird = [SKSpriteNode spriteNodeWithImageNamed:@"bird-1"];
    bird.size = CGSizeMake(bird.size.width * 2, bird.size.height * 2);
    bird.physicsBody = [SKPhysicsBody bodyWithTexture:bird.texture size:bird.size];
    bird.physicsBody.allowsRotation = NO;
    bird.physicsBody.categoryBitMask = birdCategory;
    bird.physicsBody.contactTestBitMask = floorCategory | pipeCategory;
    
    [self addChild:bird];
    
    [self shuffle];
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsWorld.contactDelegate = self;
    
    metersLabel = [SKLabelNode labelNodeWithText:@"成绩: 0米"];
    metersLabel.verticalAlignmentMode =SKLabelVerticalAlignmentModeTop;
    metersLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    metersLabel.position = CGPointMake(self.size.width / 2, self.size.height-50);
    metersLabel.zPosition = 100;
    [self addChild:metersLabel];
}

-(void)shuffle{
    gameStatus = idle;
    meter = 0;
    metersLabel.text = @"成绩: 0米";
    [self removeAllPips];
    if (_gameoverLabel) {
        [_gameoverLabel removeFromParent];
    }
    bird.physicsBody.dynamic = NO;
    bird.position = CGPointMake(self.size.width / 2, self.size.height /2);
    [self birdStartFly];
}

-(void)startGame{
    gameStatus = running;
    bird.physicsBody.dynamic = YES;
    [self startCreateRandomPipesAction];
}

-(void)gameOver{
    gameStatus = over;
    bird.physicsBody.dynamic = NO;
    [self birdStopFly];
    [self stopCreatePipes];
    [self showGameOver];
}

-(void)addPipes:(CGSize)topsize bottomSize:(CGSize)bottomSize{
    SKTexture *topTexture = [SKTexture textureWithImageNamed:@"PipeDown"];
    SKSpriteNode *topPipe = [SKSpriteNode spriteNodeWithTexture:topTexture size:topsize];
    topPipe.name = @"pipe";
    topPipe.position = CGPointMake(self.size.width+topPipe.size.width / 2 , self.size.height - topPipe.size.height /2 );
    topPipe.physicsBody = [SKPhysicsBody bodyWithTexture:topPipe.texture size:topPipe.size];
    topPipe.physicsBody.dynamic = NO;
    topPipe.physicsBody.categoryBitMask = pipeCategory;
    [self addChild:topPipe];
    
    SKTexture *bottomTexture = [SKTexture textureWithImageNamed:@"PipeUp"];
    SKSpriteNode *bottomPipe = [SKSpriteNode spriteNodeWithTexture:bottomTexture size:bottomSize];
    bottomPipe.name = @"pipe";
    bottomPipe.position = CGPointMake(self.size.width + bottomPipe.size.width /2 , floor1.size.height + bottomPipe.size.height / 2);
    bottomPipe.physicsBody = [SKPhysicsBody bodyWithTexture:bottomPipe.texture size:bottomPipe.size];
    bottomPipe.physicsBody.dynamic =NO;
    bottomPipe.physicsBody.categoryBitMask = pipeCategory;
    [self addChild:bottomPipe];
}

-(void)createRandomPipes{
    CGFloat height = self.size.height - floor1.size.height;
    CGFloat pipeGap = arc4random_uniform(bird.size.height) + bird.size.height * 2;
    CGFloat pipeWidth = 60.0;
    CGFloat topPipeHeight = arc4random_uniform(height-pipeGap);
    CGFloat bottomPipeHeight = height - pipeGap - topPipeHeight;
    [self addPipes:CGSizeMake(pipeWidth, topPipeHeight) bottomSize:CGSizeMake(pipeWidth, bottomPipeHeight)];
}

-(void)removeAllPips{
    for (SKSpriteNode *pipe in self.children) {
        if ([pipe.name isEqualToString:@"pipe"]) {
            [pipe removeFromParent];
        }
    }
}

-(void)startCreateRandomPipesAction{
    SKAction *wait = [SKAction waitForDuration:3.5 withRange:1.0];
    SKAction *generatePipe = [SKAction runBlock:^{
        [self createRandomPipes];
    }];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[wait,generatePipe]]] withKey:@"createPipe"];
}

-(void)stopCreatePipes{
    [self removeActionForKey:@"createPipe"];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {    
//    for (UITouch *t in touches) {}
    switch (gameStatus) {
        case idle:
            [self startGame];
            break;
        case running:
            NSLog(@"给小鸟一个向上的力");   //如果在游戏进行中状态下，玩家点击屏幕则给小鸟一个向上的力(暂时用print一句话代替)
            [bird.physicsBody applyImpulse:CGVectorMake(0, 30)];
            break;
        case over:
            [self shuffle];
            break;
        default:
            break;
    }
}

-(void)moveScene{
    floor1.position = CGPointMake(floor1.position.x -1 , floor1.position.y);
    floor2.position = CGPointMake(floor2.position.x -1 , floor2.position.y);
    if (floor1.position.x < -floor1.size.width) {
        floor1.position = CGPointMake(floor2.position.x + floor2.size.width , floor1.position.y);
    }
    if (floor2.position.x < -floor2.size.width) {
        floor2.position = CGPointMake(floor1.position.x + floor1.size.width , floor2.position.y);
    }
    
    for (SKSpriteNode *pipe in self.children) {
        if ([pipe.name isEqualToString:@"pipe"]) {
            pipe.position = CGPointMake(pipe.position.x -1, pipe.position.y);
            if (pipe.position.x < - pipe.size.width /2) {
                [pipe removeFromParent];
            }
        }
    }
    if (gameStatus == running) {
        meter ++;
        metersLabel.text = [NSString stringWithFormat:@"成绩: %d米",meter];
    }

}

-(void)birdStartFly{
    SKAction *fly = [SKAction animateWithTextures:@[[SKTexture textureWithImageNamed:@"bird-1"],[SKTexture textureWithImageNamed:@"bird-2"],[SKTexture textureWithImageNamed:@"bird-3"],[SKTexture textureWithImageNamed:@"bird-4"]] timePerFrame:0.15];
    [bird runAction:[SKAction repeatActionForever:fly] withKey:@"fly"];
}

-(void)birdStopFly{
    [bird removeActionForKey:@"fly"];
}

-(void)showGameOver{
    if (!_gameoverLabel) {
        _gameoverLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        _gameoverLabel.text = @"Game Over";
    }
    self.userInteractionEnabled = NO;
    [self addChild:_gameoverLabel];
    _gameoverLabel.position = CGPointMake(self.size.width /2, self.size.height);
    [_gameoverLabel runAction:[SKAction moveBy:CGVectorMake(0, -self.size.height / 2) duration:0.5] completion:^{
        self.userInteractionEnabled = YES;
    }];
    
}

//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    for (UITouch *t in touches) {
//
//    }
//}
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    for (UITouch *t in touches) {
//
//    }
//}
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    for (UITouch *t in touches) {
//
//    }
//}

- (void)didBeginContact:(SKPhysicsContact *)contact{
    if (gameStatus != running) {
        return;
    }
    SKPhysicsBody *bodyA,*bodyB;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        bodyA = contact.bodyA;
        bodyB = contact.bodyB;
    }else{
        bodyB = contact.bodyA;
        bodyA = contact.bodyB;
    }
    if ((bodyA.categoryBitMask == birdCategory && bodyB.categoryBitMask == pipeCategory) || (bodyA.categoryBitMask == birdCategory && bodyB.categoryBitMask == floorCategory)) {
        [self gameOver];
    }
    
}

-(void)update:(CFTimeInterval)currentTime {
    if (gameStatus != over) {
        [self moveScene];
    }
}

@end
