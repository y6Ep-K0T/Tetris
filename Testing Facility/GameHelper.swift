//
//  GameHelper.swift
//  Testing Facility
//
//  Created by Anzor on 08/12/16.
//  Copyright © 2016 Anzor. All rights reserved.
//

import SpriteKit
import GameplayKit

enum tetrisBlocks: Int {
    case tileNone = 0
    case tileZ = 1
    case tileS = 2
    case tileL = 3
    case tileJ = 4
    case tileT = 5
    case tileO = 6
    case tileI = 7
}

protocol tileMapDelegate {
    func createNodeOf(type type: tetrisBlocks, location: CGPoint)
}

struct tileMap {
    var delegate: tileMapDelegate?
    var tileSize = CGSize(width: 22, height: 22)
    var tileLayer: [[Int]] = Array()
    var fieldSize: CGPoint {
        get {
            return CGPoint(x: sections.x * sectionSize.x,
                           y: sections.y * sectionSize.y)
        }
    }
    var sectionSize = CGPoint(x: 22, y: 22)
    var sections = CGPoint(x: 10, y: 20)
    
    mutating func generateLevel(defaultValue: Int) {
        var columnArray: [[Int]] = Array()
        
        repeat {
            var rowArray: [Int] = Array()
            repeat {
                rowArray.append(defaultValue)
            } while rowArray.count < Int(sections.x)
            columnArray.append(rowArray)
        } while columnArray.count < Int(sections.y)
        tileLayer = columnArray
    }
    
    mutating func setTile(position position: CGPoint, toValue: Int) {
        tileLayer[Int(position.y)][Int(position.x)] = toValue
    }
    
    func getTile(position position: CGPoint) -> Int {
        return tileLayer[Int(position.y)][Int(position.x)]
    }
    
    func tileMapSize() -> CGSize {
        return CGSize(width: tileSize.width * fieldSize.x, height: tileSize.height * fieldSize.y)
    }
    
    func isValidTile(position position: CGPoint) -> Bool {
        if ((position.x >= 1) && (position.x < (fieldSize.x - 1))) && ((position.y >= 1) && (position.y < (fieldSize.y - 1))) {
            return true
        } else {
            return false
        }
    }
    
    //MARK: Level creation
    
    mutating func generateMap() {
        // Top Row
        setTemplateBy(0,
                      leftTiles: tileMapSection.sectionZ.sections,
                      middleTiles: tileMapSection.sectionS.sections,
                      rightTiles: tileMapSection.sectionI.sections)
        
        // Middle Row
        var row = 2
        repeat {
            setTemplateBy(row - 1,
                          leftTiles: tileMapSection.sectionJ.sections,
                          middleTiles: tileMapSection.sectionL.sections,
                          rightTiles: tileMapSection.sectionT.sections)
            row += 1
        } while row < Int(sections.y)
        
        // Bottom Row
        setTemplateBy((Int(sections.y) - 1),
                      leftTiles: tileMapSection.sectionO.sections,
                      middleTiles: tileMapSection.sectionO.sections,
                      rightTiles: tileMapSection.sectionO.sections)
    }
    
    mutating func setTemplateBy(rowIndex: Int, leftTiles: [[[Int]]], middleTiles: [[[Int]]], rightTiles: [[[Int]]]) {
        var randomSection = GKRandomDistribution()
        
        // Left Tiles
        randomSection = GKRandomDistribution(forDieWithSideCount: leftTiles.count)
        setTilesByTemplate(leftTiles[randomSection.nextInt() - 1], sectionIndex: CGPoint(x: 0, y: rowIndex))
        
        // Right Tiles
        randomSection = GKRandomDistribution(forDieWithSideCount: rightTiles.count)
        setTilesByTemplate(rightTiles[randomSection.nextInt() - 1], sectionIndex: CGPoint(x: Int(sections.x - 1), y: rowIndex))
        
        // Middle Tiles
        var i = 2
        randomSection = GKRandomDistribution(forDieWithSideCount: middleTiles.count)
        repeat {
            setTilesByTemplate(middleTiles[randomSection.nextInt() - 1], sectionIndex: CGPoint(x: i - 1, y: rowIndex))
            i += 1
        } while i < Int(sections.x)
    }
    
    mutating func setTilesByTemplate(template: [[Int]], sectionIndex: CGPoint) {
        for (indexr, row) in template.enumerate() {
            for (indexc, cvalue) in row.enumerate() {
                setTile(position: CGPoint(
                    x: (Int(sectionIndex.x * sectionSize.x) + indexc),
                    y: (Int(sectionIndex.y * sectionSize.y) + indexr)),
                        toValue: cvalue)
            }
        }
    }
    
    //MARK: Presenting the layer
    
    func presentLayerViaDelegate() {
        for (indexr, row) in tileLayer.enumerate() {
            for (indexc, cvalue) in row.enumerate() {
                if (delegate != nil) {
                    delegate!.createNodeOf(type: tetrisBlocks(rawValue: cvalue)!,
                                           location: CGPoint(
                                            x: tileSize.width * CGFloat(indexc),
                                            y: tileSize.height * CGFloat(-indexr)))
                }
            }
        }
    }

}
