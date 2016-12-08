//
//  GameScene.swift
//  Testing Facility
//
//  Created by Anzor on 04/10/16.
//  Copyright (c) 2016 Anzor. All rights reserved.
//

import SpriteKit
import GameplayKit
import UIKit

// Below is the class that will contain the code for Tetris clone. At least for now
class GameScene: SKScene, tileMapDelegate {
    let ZShape = SKSpriteNode(imageNamed: "ZShape.png")
    let SShape = SKSpriteNode(imageNamed: "SShape.png")
    let LShape = SKSpriteNode(imageNamed: "LShape.png")
    let JShape = SKSpriteNode(imageNamed: "JShape.png")
    let TShape = SKSpriteNode(imageNamed: "TShape.png")
    let OShape = SKSpriteNode(imageNamed: "OShape.png")
    let IShape = SKSpriteNode(imageNamed: "IShape.png")
    
    var worldGen = tileMap()
    
    override func didMoveToView(view: SKView) {
        worldGen.delegate = self
        createTabs()
        createLabels()
        createButtons()
        createBlocks()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func createLabels() {
        let levelLabel = SKLabelNode(fontNamed:"Copperplate")
        levelLabel.text = "Level 0"
        levelLabel.fontSize = 30
        levelLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) + 210)
        self.addChild(levelLabel)
        
        let scoreLabel = SKLabelNode(fontNamed:"Copperplate")
        scoreLabel.text = "Score"
        scoreLabel.fontSize = 30
        scoreLabel.position = CGPoint(x: CGRectGetMinX(self.frame) + 420, y: CGRectGetMaxY(self.frame) - 70)
        self.addChild(scoreLabel)
        
        let lineLabel = SKLabelNode(fontNamed:"Copperplate")
        lineLabel.text = "Lines: 0"
        lineLabel.fontSize = 30
        lineLabel.position = CGPoint(x: CGRectGetMinX(self.frame) + 420, y: CGRectGetMaxY(self.frame) - 130)
        self.addChild(lineLabel)
        
        let nextLabel = SKLabelNode(fontNamed:"Copperplate")
        nextLabel.text = "NEXT:"
        nextLabel.fontSize = 30
        nextLabel.position = CGPoint(x: CGRectGetMaxX(self.frame) - 420, y: CGRectGetMaxY(self.frame) - 70)
        self.addChild(nextLabel)
        
        let pointsLabel = SKLabelNode(fontNamed:"Copperplate")
        pointsLabel.text = "\(22 + 21 * 19)"
        pointsLabel.fontSize = 30
        pointsLabel.position = CGPoint(x: CGRectGetMinX(self.frame) + 420, y: CGRectGetMaxY(self.frame) - 100)
        self.addChild(pointsLabel)
    }
    
    func createTabs() {
        let fieldLayer = CAShapeLayer()
        fieldLayer.path = UIBezierPath(roundedRect: CGRect(x: 88, y: 180, width: 187, height: 387), cornerRadius: 2).CGPath
        fieldLayer.strokeColor = UIColor.blackColor().CGColor
        fieldLayer.fillColor = UIColor.clearColor().CGColor
        view!.layer.addSublayer(fieldLayer)
        
        let scoreLayer = CAShapeLayer()
        scoreLayer.path = UIBezierPath(roundedRect: CGRect(x: 25, y: 40, width: 160, height: 80), cornerRadius: 2).CGPath
        scoreLayer.strokeColor = UIColor.blackColor().CGColor
        scoreLayer.fillColor = UIColor.clearColor().CGColor
        view!.layer.addSublayer(scoreLayer)
        
        let nextLayer = CAShapeLayer()
        nextLayer.path = UIBezierPath(roundedRect: CGRect(x: 190, y: 40, width: 160, height: 80), cornerRadius: 2).CGPath
        nextLayer.strokeColor = UIColor.blackColor().CGColor
        nextLayer.fillColor = UIColor.clearColor().CGColor
        view!.layer.addSublayer(nextLayer)
        
        let levelLayer = CAShapeLayer()
        levelLayer.path = UIBezierPath(roundedRect: CGRect(x: 123, y: 130, width: 125, height: 25), cornerRadius: 2).CGPath
        levelLayer.strokeColor = UIColor.blackColor().CGColor
        levelLayer.fillColor = UIColor.clearColor().CGColor
        view!.layer.addSublayer(levelLayer)
        
        let arrowLeftLayer = CAShapeLayer()
        arrowLeftLayer.path = UIBezierPath(roundedRect: CGRect(x: 15, y: 267, width: 60, height: 200), cornerRadius: 10).CGPath
        arrowLeftLayer.strokeColor = UIColor.blackColor().CGColor
        arrowLeftLayer.fillColor = UIColor.clearColor().CGColor
        view!.layer.addSublayer(arrowLeftLayer)
        
        let arrowRightLayer = CAShapeLayer()
        arrowRightLayer.path = UIBezierPath(roundedRect: CGRect(x: 297, y: 267, width: 60, height: 200), cornerRadius: 10).CGPath
        arrowRightLayer.strokeColor = UIColor.blackColor().CGColor
        arrowRightLayer.fillColor = UIColor.clearColor().CGColor
        view!.layer.addSublayer(arrowRightLayer)
        
        let arrowDownLayer = CAShapeLayer()
        arrowDownLayer.path = UIBezierPath(roundedRect: CGRect(x: 85, y: 582, width: 200, height: 60), cornerRadius: 10).CGPath
        arrowDownLayer.strokeColor = UIColor.blackColor().CGColor
        arrowDownLayer.fillColor = UIColor.clearColor().CGColor
        view!.layer.addSublayer(arrowDownLayer)
    }
    
    func createButtons() {
        var arrowLeftPath: CGPath {
            let bezierPath = UIBezierPath()
            bezierPath.moveToPoint(CGPointMake(365, 390))
            bezierPath.addLineToPoint(CGPointMake(365, 300))
            bezierPath.addLineToPoint(CGPointMake(325, 345))
            bezierPath.addLineToPoint(CGPointMake(365, 390))
            return bezierPath.CGPath
        }
        let arrowLeft = SKShapeNode(path: arrowLeftPath)
        arrowLeft.strokeColor = SKColor.whiteColor()
        arrowLeft.lineWidth = 3
        arrowLeft.fillColor = SKColor.clearColor()
        addChild(arrowLeft)
        
        var arrowRightPath: CGPath {
            let bezierPath = UIBezierPath()
            bezierPath.moveToPoint(CGPointMake(655, 390))
            bezierPath.addLineToPoint(CGPointMake(655, 300))
            bezierPath.addLineToPoint(CGPointMake(695, 345))
            bezierPath.addLineToPoint(CGPointMake(655, 390))
            return bezierPath.CGPath
        }
        let arrowRight = SKShapeNode(path: arrowRightPath)
        arrowRight.strokeColor = SKColor.whiteColor()
        arrowRight.lineWidth = 3
        arrowRight.fillColor = SKColor.clearColor()
        addChild(arrowRight)
        
        var arrowDownPath: CGPath {
            let bezierPath = UIBezierPath()
            bezierPath.moveToPoint(CGPointMake(463, 80))
            bezierPath.addLineToPoint(CGPointMake(553, 80))
            bezierPath.addLineToPoint(CGPointMake(508, 40))
            bezierPath.addLineToPoint(CGPointMake(463, 80))
            return bezierPath.CGPath
        }
        let arrowDown = SKShapeNode(path: arrowDownPath)
        arrowDown.strokeColor = SKColor.whiteColor()
        arrowDown.lineWidth = 3
        arrowDown.fillColor = SKColor.clearColor()
        addChild(arrowDown)
    }
    
    func createBlocks() {
        worldGen.generateMap()
    }
}
