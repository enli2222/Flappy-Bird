//
//  GameViewController.m
//  Flappy Bird
//
//  Created by enli on 2018/10/12.
//  Copyright © 2018年 enli. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"

@implementation GameViewController

- (void)loadView {
    self.view = [[SKView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    SKView *skv = (SKView *)self.view;
    // Load the SKScene from 'GameScene.sks'
    GameScene *scene = [[GameScene alloc] initWithSize:[UIScreen mainScreen].bounds.size];

    // Set the scale mode to scale to fit the window
    scene.scaleMode = SKSceneScaleModeAspectFill;

    // Present the scene
    [skv presentScene:scene];
    skv.ignoresSiblingOrder = YES;
    skv.showsFPS = YES;
    skv.showsNodeCount = YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
