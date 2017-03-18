//
//  GameViewController.swift
//  MazePhone
//
//  Created by Mike Daskaloff on 06.03.17.
//  Copyright © 2017 Milko Daskalov. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    var scene: GameScene?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
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

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
        
    @IBAction func tapGestureRecognized(_ sender: UITapGestureRecognizer) {
        scene?.tap(at: sender.location(in: sender.view))
    }
    
    @IBAction func doubleTapGestureRecognized(_ sender: UITapGestureRecognizer) {
        scene?.doubleTap()
    }
    
    @IBAction func longPressGestureRecognized(_ sender: UILongPressGestureRecognizer) {
        scene?.longPress()
    }
    
    @IBAction func panGestureRecognized(_ sender: UIPanGestureRecognizer) {
        
        if let scene = self.scene, let view = sender.view {
            let location = sender.location(in: view)
            let translation = sender.translation(in: view)
            let velocity = sender.velocity(in: view)
            
            let cameraLocation = scene.convertPoint(fromView: CGPoint(x: -location.x, y: -location.y))
            let cameraTranslation = CGPoint(x: -translation.x, y: translation.y)
            let cameraVelocity = CGPoint(x: -velocity.x, y: velocity.y)
            
            if sender.state == .began {
                scene.panBegan(location: cameraLocation, translation: cameraTranslation, velocity: cameraVelocity)
                sender.setTranslation(CGPoint(x: 0, y:0), in: view)
            }
            else if sender.state == .changed {
                scene.panChanged(location: cameraLocation, translation: cameraTranslation, velocity: cameraVelocity)
            }
            else if sender.state == .ended {
                scene.panEnded(location: cameraLocation, translation: cameraTranslation, velocity: cameraVelocity)
                sender.setTranslation(CGPoint(x: 0, y:0), in: view)
            }
        }
    }
    
    
    @IBAction func rotateGestureRecognized(_ sender: UIRotationGestureRecognizer) {
    }
    
    @IBAction func pinchGestureRecognizer(_ sender: UIPinchGestureRecognizer) {
        if let scene = self.scene, let view = sender.view {
            let location = sender.location(in: view)
            let cameraLocation = scene.convertPoint(fromView: CGPoint(x: -location.x, y: -location.y))

            if sender.state == .began {
                scene.pinchBegan(location: cameraLocation, scale: sender.scale, velocity: sender.velocity)
            }
            else if sender.state == .changed {
                scene.pinchChanged(location: cameraLocation, scale: sender.scale, velocity: sender.velocity)
            }
            else if sender.state == .ended {
                scene.pinchEnded(location: cameraLocation, scale: sender.scale, velocity: sender.velocity)
            }
        }
    }
 
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
