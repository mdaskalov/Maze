//
//  GameScene.swift
//  Maze
//
//  Created by Milko Daskalov on 05.03.17.
//  Copyright © 2017 Milko Daskalov. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    let boxSize = 3
    let boxMapSize = 30
    
    private var maze: MazeTileMapNode?
    private var touchPos: CGPoint?
    
    override func didMove(to view: SKView) {
        if let label = self.childNode(withName: "//readyLabel") as? SKLabelNode {
            label.run(SKAction.fadeOut(withDuration: 2.0))
        }
                
        let maze = MazeTileMapNode(columns: boxMapSize, rows: boxMapSize, boxSize: boxSize)
        
        maze.position.x = 0
        maze.position.y = 0
        self.addChild(maze)
        self.maze = maze
            
        self.maze = maze
        touchPos = maze.position
        
        maze.cutMaze()
    }

    func touchDown(atPoint pos : CGPoint) {
        touchPos=pos
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if (touchPos != nil) {
            let moveBy = CGVector(dx: pos.x - touchPos!.x, dy: pos.y - touchPos!.y)
            //let moveDir = CGFloat(atan2f(Float(moveBy.dx),Float(-moveBy.dy)))
            maze?.position.x += moveBy.dx
            maze?.position.y += moveBy.dy
            touchPos = pos
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    func zoom(by: CGPoint) {
        let decrement = by.y / 12
        let mazeScale = maze!.xScale
        if (mazeScale-decrement) > 0.05 {
          maze?.xScale -= decrement
          maze?.yScale -= decrement
        }
        else {
            maze?.xScale = 0.05
            maze?.yScale = 0.05
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
