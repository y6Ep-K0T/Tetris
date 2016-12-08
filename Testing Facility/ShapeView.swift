//
//  ShapeView.swift
//  Testing Facility
//
//  Created by Anzor on 04/10/16.
//  Copyright © 2016 Anzor. All rights reserved.
//

import UIKit
import SpriteKit

let TileWidth: CGFloat = 320.0 / NumColumns

let TileHeight: CGFloat = 320.0 / NumRows

let TIMED_MODE = 0

let MOVES_MODE = 1

class MyScene {
    var cellTextures = [AnyHashable: Any]()
    var moveChain = [Any]()
    var spriteColors = [Any]()
    var gameMode = 0
    var cellSprites = [SKSpriteNode](repeating: SKSpriteNode(), count: NumColumns)
    
    override init(size: CGSize) {
        super.init(size)
        
        cellTextures = [AnyHashable: Any]()
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = SKColor(red: 0.15, green: 0.15, blue: 0.3, alpha: 1.0)
        self.gameLayer = SKNode.node
        self.addChild(self.gameLayer)
        var layerPosition = CGPoint(x: -TileWidth * NumColumns / 2, y: -TileHeight * NumRows / 2)
        self.cellsLayer = SKNode.node
        self.cellsLayer.position = layerPosition
        self.gameLayer.addChild(self.cellsLayer)
        
    }
    //TODO rename method, add parameters - decreasingResourceValue and score
    
    func updateCounters() {
        self.countdownValue.text = "\(Int(self.level.decreasingResourceValue))"
        self.scoreValue.text = "\(self.level.score)"
    }
    //TODO move to View
    
    func showSelectionIndicator(forCell cellPoint: CellPoint) {
        cellSprites[cellPoint.column][cellPoint.row].colorBlendFactor = 0.0
    }
    //TODO move to View
    
    func hideSelectionIndicator(_ cellPoint: CellPoint) {
        cellSprites[cellPoint.column][cellPoint.row].colorBlendFactor = HIGHLIGHTING_FACTOR
    }
    //TODO move to View
    
    func addSpritesForCells() {
        for c in 0..<NumColumns {
            for r in 0..<NumRows {
                var cellType = self.level.cellType(atColumn: c, row: r)
                if cellType == 0 {
                    cellSprites[c][r] = nil
                }
                var sprite = self.createCellSprite(cellType)
                sprite.position = self.point(forColumn: c, row: r)
                cellSprites[c][r] = sprite
                self.cellsLayer.addChild(sprite)
            }
        }
    }
    //TODO move to View
    
    func point(forColumn column: Int, row: Int) -> CGPoint {
        return CGPoint(x: column * TileWidth + TileWidth / 2, y: row * TileHeight + TileHeight / 2)
    }
    
    // The output below is limited by 1 KB.
    // Please Sign Up (Free!) to remove this limitation.
    
    //TODO move to View
    
    func createCellSprite(cellType: Int) -> SKSpriteNode {
        var color = self.spriteColor(cellType)
        var texture = self.cellTexture(with: color)
        var sprite = SKSpriteNode.withTexture(texture)
        sprite.color = SKColor.black
        sprite.colorBlendFactor = HIGHLIGHTING_FACTOR
        return sprite
    }
    //TODO move to View
    
    func cellTexture(with color: SKColor) -> SKTexture {
        var texture = (cellTextures[color] as! String)
        if texture != nil {
            return texture
        }
        UIImage * image
        var targetSize = CGSize(width: TileWidth - 2, height: TileHeight - 2)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        var targetRect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        var path = UIBezierPath(roundedRect: targetRect, cornerRadius: TileWidth / 8)
        color.setFill()
        path.fill()
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    //TODO extract part of body to method and move to View
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var touch = touches.first!
        var location = touch.location(inNode: self.cellsLayer)
        var point = self.convert2Point(location)
        if !point {
            return
        }
        var cellType = self.level.cellType(atColumn: point.column, row: point.row)
        if cellType == 0 {
            return
        }
        moveChain = [Any]()
        moveChain.append(point)
        self.showSelectionIndicator(forCell: point)
    }
    
    //TODO extract part of body to method and move to View
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if moveChain.isEmpty {
            return
        }
        var touch = touches.first!
        var location = touch.location(inNode: self.cellsLayer)
        var point = self.convert2Point(location)
        if !point {
            return
        }
        var cellType = self.level.cellType(atColumn: point.column, row: point.row)
        if cellType == 0 {
            return
        }
        if (moveChain as NSArray).indexOfObject(passingTest: {(obj: Any, idx: Int, stop: Bool) -> Void in
            var cell = (obj as! CellPoint)
            var result = (cell.column == point.column && cell.row == point.row) ? true : false
            return result
        }) != NSNotFound {
            return
        }
        var lastCell = moveChain.last!
        if lastCell && !self.areNeighbours(lastCell, and: point) {
            return
        }
        moveChain.append(point)
        self.showSelectionIndicator(forCell: point)
    }
    
    func areNeighbours(_ cell: CellPoint, and other: CellPoint) -> Bool {
        if cell.column != other.column && cell.row != other.row {
            return false
        }
        if abs(cell.column - other.column) > 1 {
            return false
        }
        if abs(cell.row - other.row) > 1 {
            return false
        }
        return true
    }
    //TODO extract part of body to method and move to View
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if moveChain.isEmpty {
            return
        }
        var emptyLoc = self.level.findEmptyCell()
        if !self.areNeighbours(emptyLoc, and: moveChain.last!) {
            self.dropChain()
            return
        }
        self.processMoveChain()
    }
    
    
    func dropChain() {
        for cell: CellPoint in moveChain {
            self.hideSelectionIndicator(cell)
        }
        moveChain = nil
    }
    //TODO move to View
    
    func processMoveChain() {
        self.userInteractionEnabled = false
        var empty = self.level.findEmptyCell()
        var slides = [Any]()
        var column = empty.column
        var row = empty.row
        var i = Int(moveChain.count) - 1
        while i >= 0 {
            var slide = Slide()
            var point = moveChain[i]
            slide.column = point.column
            slide.row = point.row
            slide.vShift = row - point.row
            slide.hShift = column - point.column
            slides.append(slide)
            column = point.column
            row = point.row
            i -= 1
        }
        self.slide(slides)
    }
    
    
    func convert2Point(_ point: CGPoint) -> CellPoint {
        var column: Int
        var row: Int
        if point.x >= 0 && point.x < NumColumns * TileWidth && point.y >= 0 && point.y < NumRows * TileHeight {
            column = point.x / TileWidth
            row = point.y / TileHeight
            return CellPoint.withColumn(column, row: row)
        }
        else {
            return nil
        }
    }
    //TODO move to View
    
    func slide(_ slides: [Any]) {
        var removedCells = self.level.performSlides(slides)
        if gameMode == MOVES_MODE {
            self.level.decreaseResource(1)
        }
        self.animateSlides(slides, completion: {() -> Void in
            self.animateMatchedCells(removedCells, completion: {() -> Void in
                self.animateNewCells(removedCells, completion: {() -> Void in
                    self.updateCounters()
                    self.dropChain()
                    self.userInteractionEnabled = true
                    self.checkGameOver()
                })
            })
        })
    }
    
    // The output below is limited by 1 KB.
    // Please Sign Up (Free!) to remove this limitation.
    
    //TODO move to View
    
    func animateSlides(_ slides: [Any], completion: () -> ()) {
        let Duration = fmax(0.3 / slides.count, 0.08)
        self.animateMoveSlide(Duration, slides: slides, withIndex: 0, completion: completion)
    }
    //TODO move to View
    
    func animateMoveSlide(_ duration: TimeInterval, slides: [Any], with index: Int, completion: () -> ()) {
        if index == slides.count {
            completion()
            return
        }
        var slide = slides[index]
        var sprite = cellSprites[slide.column][slide.row]
        var row = slide.row + slide.vShift
        var column = slide.column + slide.hShift
        var nextSlidePoint = CellPoint.withColumn(column, row: row)
        cellSprites[column][row] = sprite
        cellSprites[slide.column][slide.row] = nil
        var slidePosition = sprite.position
        slidePosition = CGPoint(x: slidePosition.x + slide.hShift * TileWidth, y: slidePosition.y + slide.vShift * TileHeight)
        var slideAction = SKAction.move(to: slidePosition, duration: duration)
    }
    
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, withEvent: event)
    }
    //TODO move to View
    
    func animateMatchedCells(_ cells: Set<AnyHashable>, completion: () -> ()) {
        if cells.count == 0 {
            self.runAction(SKAction.runBlock(completion))
            return
        }
        for cell: CellPoint in cells {
            var sprite = cellSprites[cell.column][cell.row]
            if sprite == nil {
                print("!!! wrong attempt to remove sprite at empty cell \(cell.column) \(cell.row)")
            }
            var scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
            scaleAction.timingMode = SKActionTimingEaseOut
            sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]))
            cellSprites[cell.column][cell.row] = nil
        }
        self.runAction(SKAction.sequence([SKAction.wait(forDuration: 0.3), SKAction.runBlock(completion)]))
    }
    
    //TODO move to View
    
    func animateNewCells(_ cells: Set<AnyHashable>, completion: () -> ()) {
        if cells.count == 0 {
            self.runAction(SKAction.runBlock(completion))
            return
        }
        (cells as NSArray).enumerateObjects(usingBlock: {(removedCell: CellPoint, stop: Bool) -> Void in
            var cellType = level.cellType(atColumn: removedCell.column, row: removedCell.row)
            var sprite = self.createCellSprite(cellType)
            sprite.position = self.point(forColumn: removedCell.column, row: removedCell.row)
            self.cellsLayer.addChild(sprite)
            cellSprites[removedCell.column][removedCell.row] = sprite
            sprite.scale = 0
            var showUpAction = SKAction.scale(to: 1.0, duration: 0.3)
            showUpAction.timingMode = SKActionTimingEaseOut
            sprite.runAction(showUpAction)
        })
        self.runAction(SKAction.sequence([SKAction.wait(forDuration: 0.3), SKAction.runBlock(completion)]))
    }
    
    //TODO move to View
    
    func checkGameOver() {
        if self.level.decreasingResourceValue <= 0 {
            var gameOverMessage = UIAlertView(title: "", message: "Game over!", delegate: self, cancelButtonTitle: "Ok, start new game", otherButtonTitles: "")
            gameOverMessage.show()
        }
    }
    
    func alertView(_ alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if alertView.tag == 777 {
            self.gameMode = buttonIndex
            self.setupGameMode()
        }
        else {
            self.startNewGame()
        }
    }
    
    func setGameMode(_ index: Int) {
        gameMode = index
    }
    
    
    func startNewGame() {
        self.cellsLayer.removeAllChildren()
        self.requestGameMode()
    }
    
    func setupGameMode() {
        self.level.newGame(self.getDecreasingResource())
        self.addSpritesForCells()
        self.setupCounters()
        self.updateCounters()
    }
    
    func getDecreasingResource() -> CGFloat {
        switch gameMode {
        case TIMED_MODE:
            return 120.0
        case MOVES_MODE:
            return 20
        default:
            return 0
        }
        
    }
    
    func requestGameMode() {
        var alert = UIAlertView(title: "", message: "Choose mode:", delegate: self, cancelButtonTitle: "", otherButtonTitles: "Time", "Moves")
        alert.tag = 777
        alert.show()
    }
    
    func setupCounters() {
        switch gameMode {
        case TIMED_MODE:
            self.countdownName.text = "Time:"
            self.nextCountdownTimer()
        case MOVES_MODE:
            self.countdownName.text = "Moves:"
        }
        
    }
    
    func nextCountdownTimer() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), DispatchQueue.main, {() -> Void in
            self.level.decreaseResource(1)
            self.updateCounters()
            if self.level.decreasingResourceValue <= 0 {
                self.checkGameOver()
            }
            else {
                self.nextCountdownTimer()
            }
        })
    }
    //TODO move to View
    
    func spriteColor(_ cellType: Int) -> SKColor {
        if spriteColors == nil {
            spriteColors = [SKColor.red, SKColor.yellow, SKColor.green, SKColor.blue]
        }
        return spriteColors[cellType - 1]
    }
}