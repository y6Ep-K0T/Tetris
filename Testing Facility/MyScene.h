//
//  MyScene.h
//  Pentuzzle
//

//  Copyright (c) 2014 Pig.ru Ltd. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Level.h"

static const double HIGHLIGHTING_FACTOR = 0.3;

@interface MyScene : SKScene <UIAlertViewDelegate>

@property (strong, nonatomic) Level* level;

@property (strong, nonatomic) IBOutlet UILabel *scoreValue;
@property (strong, nonatomic) IBOutlet UILabel *countdownValue;
@property (weak, nonatomic) IBOutlet UILabel *countdownName;

- (void)updateCounters;

- (void)animateSlides:(NSArray *)slides completion:(dispatch_block_t)completion;

- (void)animateMatchedCells:(NSSet *)cells completion:(dispatch_block_t)completion;

- (void)animateNewCells:(NSSet *)chains completion:(dispatch_block_t)completion;

- (void)startNewGame;

@end
