//
//  ViewController.swift
//  Maze
//
//  Created by Milko Daskalov on 05.03.17.
//  Copyright © 2017 Milko Daskalov. All rights reserved.
//

import Cocoa
import SpriteKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    var scene: GameScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                // Present the scene
                view.presentScene(scene)
                self.scene = scene
            }
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override func scrollWheel(with event: NSEvent) {
        scene?.zoom(delta: event.deltaY)
    }
    
    @IBAction func clickGestureRecognized(_ sender: NSClickGestureRecognizer) {
        scene?.tap(at: sender.location(in: sender.view))
    }
    
    @IBAction func doubleClickGestureRecognized(_ sender: NSClickGestureRecognizer) {
        scene?.doubleTap()
    }
    
    @IBAction func pressGestureRecognized(_ sender: NSPressGestureRecognizer) {
        scene?.longPress()
    }
    
    @IBAction func panGestureRecognized(_ sender: NSPanGestureRecognizer) {
        if let scene = self.scene, let view = sender.view {
            let location = sender.location(in: view)
            let translation = sender.translation(in: view)
            let velocity = sender.velocity(in: view)
            
            if sender.state == .began {
                scene.panBegan(location: location, translation: translation, velocity: velocity)
                sender.setTranslation(CGPoint(x: 0, y:0), in: view)
            }
            else if sender.state == .changed {
                scene.panChanged(location: location, translation: translation, velocity: velocity)
            }
            else if sender.state == .ended {
                scene.panEnded(location: location, translation: translation, velocity: velocity)
                sender.setTranslation(CGPoint(x: 0, y:0), in: view)
            }
        }
    }
}

