//
//  GameScene.swift
//  MazePhone
//
//  Created by Mike Daskaloff on 06.03.17.
//  Copyright © 2017 Milko Daskalov. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let boxSize = 3
    let boxMapSize = 30
    
    private var maze: MazeTileMapNode?
     private var cameraScale: CGFloat = 1.0
    
    override func didMove(to view: SKView) {
        if let label = self.childNode(withName: "//readyLabel") as? SKLabelNode {
            label.run(SKAction.fadeOut(withDuration: 2.0))
        }
        
        let maze = MazeTileMapNode(columns: boxMapSize, rows: boxMapSize, boxSize: boxSize)
        
        maze.position.x = 0
        maze.position.y = 0
        
        self.addChild(maze)
        self.maze = maze
        
        maze.cutMaze()
    }
    
    func panBegan(location: CGPoint, translation: CGPoint, velocity: CGPoint) {
        //print(String(format: "  began Pan loc: %4.2f,%4.2f tra: %4.2f,%4.2f vel: %4.2f,%4.2f", location.x,location.y,translation.x,translation.y,velocity.x,velocity.y))
        //camera?.removeAllActions()
    }
    
    func panChanged(location: CGPoint, translation: CGPoint, velocity: CGPoint) {
        camera!.position.x += (translation.x * (camera!.xScale / 6))
        camera!.position.y += (translation.y * (camera!.yScale / 6))
        
        //print(String(format: "changed Pan loc: %4.2f,%4.2f tra: %4.2f,%4.2f vel: %4.2f,%4.2f", location.x,location.y,translation.x,translation.y,velocity.x,velocity.y))
    }
    
    func panEnded(location: CGPoint, translation: CGPoint, velocity: CGPoint) {
        camera!.position.x += (translation.x * (camera!.xScale / 6))
        camera!.position.y += (translation.y * (camera!.yScale / 6))
        
        let speedUp = SKAction.speed(to: 1.0, duration: 0)
        let moveByVelocity = SKAction.moveBy(x: (velocity.x * (camera!.xScale / 6)), y: (velocity.y * (camera!.yScale / 6)), duration: 0.2)
        let slowDown = SKAction.speed(to: 0, duration: 0.2)
        let group = SKAction.sequence([speedUp,moveByVelocity,slowDown])
        
        camera?.run(group)
 
        //print(String(format: "  ended Pan loc: %4.2f,%4.2f tra: %4.2f,%4.2f vel: %4.2f,%4.2f", location.x,location.y,translation.x,translation.y,velocity.x,velocity.y))
    }
    
    func pinchBegan(location: CGPoint, scale: CGFloat, velocity: CGFloat) {
        self.cameraScale = scale
        
        //print(String(format: "  began Pinch: loc: %4.2f,%4.2f sca: %4.2f vel: %4.2f",location.x,location.y,scale,velocity))
    }
    
    func pinchChanged(location: CGPoint, scale: CGFloat, velocity: CGFloat) {
        let deltaScale = (cameraScale - scale) * 8
        
        if ((camera!.xScale + deltaScale) > 0) {
            camera?.xScale += deltaScale
            camera?.yScale += deltaScale
        }
        cameraScale = scale
        
        //print(String(format: "changed Pinch: loc: %4.2f,%4.2f sca: %4.2f vel: %4.2f",location.x,location.y,scale,velocity))
    }

    func pinchEnded(location: CGPoint, scale: CGFloat, velocity: CGFloat) {
        //print(String(format: "  ended Pinch: loc: %4.2f,%4.2f sca: %4.2f vel: %4.2f",location.x,location.y,scale,velocity))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
