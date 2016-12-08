//
//  MyScene.m
//  Pentuzzle
//
//  Created by Tim Lianov on 03/07/14.
//  Copyright (c) 2014 Pig.ru Ltd. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"
#import "Slide.h"
#import "CellPoint.h"

static const CGFloat TileWidth = 320.0 / NumColumns;
static const CGFloat TileHeight = 320.0 / NumRows;
static const NSInteger TIMED_MODE = 0;
static const NSInteger MOVES_MODE = 1;

@interface MyScene ()

@property(strong, nonatomic) SKNode *gameLayer;
@property(strong, nonatomic) SKNode *cellsLayer;

@end

@implementation MyScene {
    NSMutableDictionary *cellTextures;
    NSMutableArray *moveChain;
    NSArray *spriteColors;
    NSInteger gameMode;
    SKSpriteNode *cellSprites[NumColumns][NumRows];
}

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {

        cellTextures = [NSMutableDictionary dictionary];

        self.anchorPoint = CGPointMake(0.5, 0.5);

        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        self.gameLayer = [SKNode node];
        [self addChild:self.gameLayer];

        CGPoint layerPosition = CGPointMake(-TileWidth * NumColumns / 2, -TileHeight * NumRows / 2);
        self.cellsLayer = [SKNode node];
        self.cellsLayer.position = layerPosition;
        [self.gameLayer addChild:self.cellsLayer];
    }
    return self;
}

//TODO rename method, add parameters - decreasingResourceValue and score
- (void)updateCounters {
    self.countdownValue.text = [NSString stringWithFormat:@"%d", (int)self.level.decreasingResourceValue];
    self.scoreValue.text = [NSString stringWithFormat:@"%d", self.level.score];
}

//TODO move to View
- (void)showSelectionIndicatorForCell:(CellPoint *)cellPoint {
    cellSprites[cellPoint.column][cellPoint.row].colorBlendFactor = 0.0;
}

//TODO move to View
- (void)hideSelectionIndicator:(CellPoint *)cellPoint {
    cellSprites[cellPoint.column][cellPoint.row].colorBlendFactor = HIGHLIGHTING_FACTOR;
}

//TODO move to View
- (void)addSpritesForCells {
    for (int c = 0; c < NumColumns; c++) {
        for (int r = 0; r < NumRows; r++) {
            int cellType = [self.level cellTypeAtColumn:c row:r];
            if (cellType == 0) {
                cellSprites[c][r] = nil;
                continue;
            }
            SKSpriteNode *sprite = [self createCellSprite:cellType];
            sprite.position = [self pointForColumn:c row:r];
            cellSprites[c][r] = sprite;
            [self.cellsLayer addChild:sprite];
        }
    }
}

//TODO move to View
- (CGPoint)pointForColumn:(int)column row:(int)row {
    return CGPointMake(column * TileWidth + TileWidth / 2, row * TileHeight + TileHeight / 2);
}

//TODO move to View
- (SKSpriteNode *)createCellSprite:(int)cellType {
    SKColor *color = [self spriteColor:cellType];
    SKTexture *texture = [self cellTextureWithColor:color];
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:texture];
    sprite.color = [SKColor blackColor];
    sprite.colorBlendFactor = HIGHLIGHTING_FACTOR;
    return sprite;
}

//TODO move to View
- (SKTexture *)cellTextureWithColor:(SKColor *)color {

    SKTexture *texture = [cellTextures objectForKey:color];

    if (texture != nil) {
        return texture;
    }

    UIImage *image;

    CGSize targetSize = CGSizeMake(TileWidth - 2, TileHeight - 2);

    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 1.0);

    CGRect targetRect = CGRectMake(0, 0, targetSize.width, targetSize.height);

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:targetRect cornerRadius:TileWidth / 8];

    [color setFill];
    [path fill];

    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    texture = [SKTexture textureWithImage:image];

    [cellTextures setObject:texture forKey:color];

    return texture;
}

//TODO extract part of body to method and move to View
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self.cellsLayer];

    CellPoint *point = [self convert2Point:location];

    if (!point) {
        return;
    }

    int cellType = [self.level cellTypeAtColumn:point.column row:point.row];

    if (cellType == 0) {
        return;
    }

    moveChain = [NSMutableArray array];
    [moveChain addObject:point];
    [self showSelectionIndicatorForCell:point];

}

//TODO extract part of body to method and move to View
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!moveChain) {
        return;
    }

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self.cellsLayer];

    CellPoint *point = [self convert2Point:location];
    if (!point) {
        return;
    }

    int cellType = [self.level cellTypeAtColumn:point.column row:point.row];

    if (cellType == 0) {
        return;
    }

    if ([moveChain indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
        CellPoint *cell = (CellPoint *) obj;
        BOOL result = (cell.column == point.column && cell.row == point.row) ? YES : NO;
        return result;
    }] != NSNotFound) {
        return;
    }

    CellPoint *lastCell = [moveChain lastObject];
    if (lastCell && ![self areNeighbours:lastCell and:point]) {
        return;
    }

    [moveChain addObject:point];
    [self showSelectionIndicatorForCell:point];

}

//TODO move to View (or Level)
- (BOOL)areNeighbours:(CellPoint *)cell and:(CellPoint *)other {
    if (cell.column != other.column && cell.row != other.row) {
        return NO;
    }

    if (abs(cell.column - other.column) > 1) {
        return NO;
    }

    if (abs(cell.row - other.row) > 1) {
        return NO;
    }

    return YES;
}


//TODO extract part of body to method and move to View
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    if (!moveChain) {
        return;
    }

    CellPoint *emptyLoc = [self.level findEmptyCell];

    if (![self areNeighbours:emptyLoc and:[moveChain lastObject]]) {
        [self dropChain];
        return;
    }

    [self processMoveChain];
}

//TODO move to View
- (void)dropChain {
    for (CellPoint *cell in moveChain) {
        [self hideSelectionIndicator:cell];
    }
    moveChain = nil;
}


//TODO move to View
- (void)processMoveChain {
    self.userInteractionEnabled = NO;

    CellPoint *empty = [self.level findEmptyCell];

    NSMutableArray *slides = [NSMutableArray array];
    int column = empty.column;
    int row = empty.row;

    for (int i = (int) moveChain.count - 1; i >= 0; i--) {
        Slide *slide = [[Slide alloc] init];
        CellPoint *point = [moveChain objectAtIndex:i];
        slide.column = point.column;
        slide.row = point.row;
        slide.vShift = row - point.row;
        slide.hShift = column - point.column;
        [slides addObject:slide];
        column = point.column;
        row = point.row;
    }
    [self slide:slides];
}

//TODO move to View
- (CellPoint *)convert2Point:(CGPoint)point {
    int column;
    int row;
    if (point.x >= 0 && point.x < NumColumns * TileWidth && point.y >= 0 && point.y < NumRows * TileHeight) {
        column = point.x / TileWidth;
        row = point.y / TileHeight;
        return [CellPoint withColumn:column row:row];
    } else {
        return nil;
    }
}


//TODO move to View
- (void)slide:(NSMutableArray *)slides {
    NSSet *removedCells = [self.level performSlides:slides];
    if(gameMode == MOVES_MODE) {
        [self.level decreaseResource:1];
    }
    [self animateSlides:slides completion:^{
        [self animateMatchedCells:removedCells completion:^{
            [self animateNewCells:removedCells completion:^{
                [self updateCounters];
                [self dropChain];
                self.userInteractionEnabled = YES;
                [self checkGameOver];
            }];
        }];
    }];
}


//TODO move to View
- (void)animateSlides:(NSMutableArray *)slides completion:(dispatch_block_t)completion {
    const NSTimeInterval Duration = fmax(0.3 / slides.count, 0.08);
    [self animateMoveSlide:Duration slides:slides withIndex:0 completion:completion];
}

//TODO move to View
- (void)animateMoveSlide:(NSTimeInterval const)duration slides:(NSMutableArray *)slides withIndex:(int)index completion:(dispatch_block_t)completion {
    if (index == slides.count) {
        completion();
        return;
    }
    Slide *slide = [slides objectAtIndex:index];
    SKSpriteNode *sprite = cellSprites[slide.column][slide.row];
    int row = slide.row + slide.vShift;
    int column = slide.column + slide.hShift;
    CellPoint *nextSlidePoint = [CellPoint withColumn:column row:row];
    cellSprites[column][row] = sprite;
    cellSprites[slide.column][slide.row] = nil;
    CGPoint slidePosition = sprite.position;
    slidePosition = CGPointMake(slidePosition.x + slide.hShift * TileWidth, slidePosition.y + slide.vShift * TileHeight);
    SKAction *slideAction = [SKAction moveTo:slidePosition duration:duration];
    slideAction.timingMode = SKActionTimingEaseOut;
    CellPoint *slidePoint = [CellPoint withColumn:slide.column row:slide.row];
    [self showSelectionIndicatorForCell:slidePoint];
    [sprite runAction:[SKAction sequence:@[slideAction, [SKAction runBlock:^{
        [self hideSelectionIndicator:nextSlidePoint];
        [self animateMoveSlide:duration slides:slides withIndex:index + 1 completion:completion];
    }]]]];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}


//TODO move to View
- (void)animateMatchedCells:(NSSet *)cells completion:(dispatch_block_t)completion {
    if (cells.count == 0) {
        [self runAction:[SKAction runBlock:completion]];
        return;
    }
    for (CellPoint *cell in cells) {
        SKSpriteNode *sprite = cellSprites[cell.column][cell.row];
        if (sprite == nil) {
            NSLog(@"!!! wrong attempt to remove sprite at empty cell %d %d", cell.column, cell.row);
            continue;
        }
        SKAction *scaleAction = [SKAction scaleTo:0.1 duration:0.3];
        scaleAction.timingMode = SKActionTimingEaseOut;
        [sprite runAction:[SKAction sequence:@[scaleAction, [SKAction removeFromParent]]]];
        cellSprites[cell.column][cell.row] = nil;
    }
    [self runAction:[SKAction sequence:@[
            [SKAction waitForDuration:0.3],
            [SKAction runBlock:completion]
    ]]];
}

//TODO move to View
- (void)animateNewCells:(NSSet *)cells completion:(dispatch_block_t)completion {
    if (cells.count == 0) {
        [self runAction:[SKAction runBlock:completion]];
        return;
    }

    [cells enumerateObjectsUsingBlock:^(CellPoint *removedCell, BOOL *stop) {

        int cellType = [_level cellTypeAtColumn:removedCell.column row:removedCell.row];

        SKSpriteNode *sprite = [self createCellSprite:cellType];
        sprite.position = [self pointForColumn:removedCell.column row:removedCell.row];
        [self.cellsLayer addChild:sprite];
        cellSprites[removedCell.column][removedCell.row] = sprite;

        [sprite setScale:0];
        SKAction *showUpAction = [SKAction scaleTo:1.0 duration:0.3];
        showUpAction.timingMode = SKActionTimingEaseOut;
        [sprite runAction:showUpAction];
    }];

    [self runAction:[SKAction sequence:@[
            [SKAction waitForDuration:0.3],
            [SKAction runBlock:completion]
    ]]];

}

//TODO move to View
- (void)checkGameOver {
    if (self.level.decreasingResourceValue <= 0) {
        UIAlertView *gameOverMessage = [[UIAlertView alloc] initWithTitle:nil
                                                                  message:@"Game over!"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Ok, start new game"
                                                        otherButtonTitles:nil];
        [gameOverMessage show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 777) {
       [self setGameMode: buttonIndex];
        [self setupGameMode];
    } else {
        [self startNewGame];
    }
}

- (void)setGameMode:(NSInteger)index {
    gameMode = index;
}

- (void)startNewGame {
    [self.cellsLayer removeAllChildren];
    [self requestGameMode];
}

- (void)setupGameMode {
    [self.level newGame:[self getDecreasingResource]];
    [self addSpritesForCells];
    [self setupCounters];
    [self updateCounters];
}

- (CGFloat)getDecreasingResource {
    switch(gameMode) {
        case TIMED_MODE:
            return 120.0;
        case MOVES_MODE:
            return 20;
        default:
            return 0;
    }
}

- (void)requestGameMode {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Choose mode:"
                                              delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Time", @"Moves", nil];
    alert.tag = 777;
    [alert show];
}

- (void)setupCounters {
    switch(gameMode) {
        case TIMED_MODE:
            _countdownName.text = @"Time:";
            [self nextCountdownTimer];
            break;
        case MOVES_MODE:
            _countdownName.text = @"Moves:";
            break;
    }
}

- (void)nextCountdownTimer {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.level decreaseResource:1];
        [self updateCounters];
        if (self.level.decreasingResourceValue <= 0) {
             [self checkGameOver];
         } else {
             [self nextCountdownTimer];
         }
    });

}

//TODO move to View
- (SKColor *)spriteColor:(int)cellType {
    if (spriteColors == nil) {
        spriteColors = @[
                [SKColor redColor],
                [SKColor yellowColor],
                [SKColor greenColor],
                [SKColor blueColor],
        ];
    }
    return [spriteColors objectAtIndex:cellType - 1];
}

@end
