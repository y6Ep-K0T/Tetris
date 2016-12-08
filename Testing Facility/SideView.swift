//
//  SideView.swift
//  Testing Facility
//
//  Created by Anzor on 13/10/16.
//  Copyright © 2016 Anzor. All rights reserved.
//

import SpriteKit
let HIGHLIGHTING_FACTOR: Double = 0.3

class MyScene: SKScene, UIAlertViewDelegate {
    var level: Level!
    @IBOutlet var scoreValue: UILabel!
    @IBOutlet var countdownValue: UILabel!
    @IBOutlet weak var countdownName: UILabel!
    
    func updateCounters() {
    }
    
    func animateSlides(_ slides: [Any], completion: () -> ()) {
    }
    
    func animateMatchedCells(_ cells: Set<AnyHashable>, completion: () -> ()) {
    }
    
    func animateNewCells(_ chains: Set<AnyHashable>, completion: () -> ()) {
    }
    
    func startNewGame() {
    }
}