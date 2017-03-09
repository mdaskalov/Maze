//
//  InterfaceController.swift
//  MazeWatch Extension
//
//  Created by Mike Daskaloff on 07.03.17.
//  Copyright © 2017 Milko Daskalov. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController, WKCrownDelegate {

    @IBOutlet var skInterface: WKInterfaceSKScene!
    
    var moving = false
    var value = 1.0
    var rps = 0.0
    
    var scene: GameScene?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        crownSequencer.focus()
        crownSequencer.delegate = self
        
        // Load the SKScene from 'GameScene.sks'
        if let scene = GameScene(fileNamed: "GameScene") {
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            self.skInterface.presentScene(scene)
            
            // Use a value that will maintain a consistent frame rate
            self.skInterface.preferredFramesPerSecond = 30
            
            self.scene = scene
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    //MARK: Crown Delegates
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        value += rotationalDelta
        rps = (crownSequencer?.rotationsPerSecond)!
        moving = true
        
        if value > 35 {
            value = 35
        }
        
        if value < 0.45 {
            value = 0.45
        }
        
        scene?.zoom(by: CGFloat(value))
    }
    
    func crownDidBecomeIdle(_ crownSequencer: WKCrownSequencer?) {
        rps = (crownSequencer?.rotationsPerSecond)!
        moving = false
    }
    
    @IBAction func panGestureRecognized(_ sender: WKPanGestureRecognizer) {
        let location = CGPoint(x: sender.locationInObject().x, y: -sender.locationInObject().y)
        
        switch sender.state {
        case .began:
            scene?.touchDown(atPoint: location)
            
        case .cancelled, .ended, .changed:
            scene?.touchMoved(toPoint: location)
            
        default:
            debugPrint("Unhandled gesture state: \(sender.state)")
        }
    }
    
}
