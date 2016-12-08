//
//  GameViewController.swift
//  Testing Facility
//
//  Created by Anzor on 04/10/16.
//  Copyright (c) 2016 Anzor. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, UIScrollViewDelegate {
    var scrollView: UIScrollView!
    var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView = UIScrollView(frame: view.bounds)
        scrollView.contentSize = view.bounds.size
        scrollView.autoresizingMask = UIViewAutoresizing.FlexibleWidth; UIViewAutoresizing.FlexibleHeight
        scrollView.contentOffset = CGPoint(x: 655, y: 350)
        
        view.addSubview(scrollView)
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = 0.1
    }
    
    func didTap(tapGR: UITapGestureRecognizer) {
        /*
        // let tapPoint = tapGR.locationInView(self.view)
        
        // Field
        var fieldYAxis = 580
        var fieldXAxis = 97
        var fieldShapeView = ShapeView(origin: CGPoint(x: fieldXAxis, y: fieldYAxis))
        self.view.addSubview(fieldShapeView)
        while fieldXAxis < 297 {
            while fieldYAxis > 200 {
                fieldYAxis = fieldYAxis - 20
                fieldShapeView = ShapeView(origin: CGPoint(x: fieldXAxis, y: fieldYAxis))
                self.view.addSubview(fieldShapeView)
            }
            fieldYAxis = 600
            fieldXAxis = fieldXAxis + 20
        }
        
        // Score
        var scoreXAxis = 35
        var scoreYAxis = 50
        var scoreShapeView = ShapeView(origin: CGPoint(x: scoreXAxis, y: scoreYAxis))
        self.view.addSubview(scoreShapeView)
        while scoreXAxis < 195 {
            while scoreYAxis < 110 {
                scoreYAxis = scoreYAxis + 20
                scoreShapeView = ShapeView(origin: CGPoint(x: scoreXAxis, y: scoreYAxis))
                self.view.addSubview(scoreShapeView)
            }
            scoreYAxis = 30
            scoreXAxis = scoreXAxis + 20
        }
        
        // Next block
        var nextXAxis = 340
        var nextYAxis = 50
        var nextShapeView = ShapeView(origin: CGPoint(x: nextXAxis, y: nextYAxis))
        self.view.addSubview(nextShapeView)
        while nextXAxis > 180 {
            while nextYAxis < 110 {
                nextYAxis = nextYAxis + 20
                nextShapeView = ShapeView(origin: CGPoint(x: nextXAxis, y: nextYAxis))
                self.view.addSubview(nextShapeView)
            }
            nextYAxis = 30
            nextXAxis = nextXAxis - 20
        }
        
        // Level
        var levelXAxis = 137
        let levelYAxis = 175
        var levelShapeView = ShapeView(origin: CGPoint(x: levelXAxis, y: levelYAxis))
        self.view.addSubview(levelShapeView)
        while levelXAxis < 237 {
            levelXAxis = levelXAxis + 20
            levelShapeView = ShapeView(origin: CGPoint(x: levelXAxis, y: levelYAxis))
            self.view.addSubview(levelShapeView)
        }
        */
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}