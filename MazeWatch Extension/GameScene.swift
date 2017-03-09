//
//  GameScene.swift
//  MazeWatch Extension
//
//  Created by Mike Daskaloff on 07.03.17.
//  Copyright © 2017 Milko Daskalov. All rights reserved.
//

import WatchKit
import SpriteKit

class GameScene: SKScene {
    
    let boxSize = 3
    let boxMapSize = 20
    
    private var maze: MazeTileMapNode?
    private var touchPos: CGPoint?
    
    override func sceneDidLoad() {
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
            let moveBy = CGVector(dx: touchPos!.x - pos.x, dy: touchPos!.y - pos.y)
            //let moveDir = CGFloat(atan2f(Float(moveBy.dx),Float(-moveBy.dy)))
            camera?.position.x += (moveBy.dx * camera!.xScale)
            camera?.position.y += (moveBy.dy * camera!.xScale)
            touchPos = pos
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    func zoom(by: CGFloat) {
        camera?.xScale = by
        camera?.yScale = by
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
