//
//  GameScene.swift
//  MazePhone
//
//  Created by Mike Daskaloff on 06.03.17.
//  Copyright © 2017 Milko Daskalov. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    private let boxSize = 3
    private let boxMapWidth = 30
    private let boxMapHeight = 54
    
    private var maze: MazeTileMapNode?
    private var cameraScale: CGFloat = 1.0
    
    private var timer : Timer?
    private var cutPathNodes = Array<SKSpriteNode>()

    override func didMove(to view: SKView) {
        if let label = self.childNode(withName: "//readyLabel") as? SKLabelNode {
            label.run(SKAction.fadeOut(withDuration: 2.0))
        }

        let maze = MazeTileMapNode(columns: boxMapWidth, rows: boxMapHeight, boxSize: boxSize)
        
        maze.position.x = 0
        maze.position.y = 0
        
        self.camera?.setScale(21.0)
        self.addChild(maze)
        self.maze = maze
        
        resetCut()
    }
    
    func drawBox(_ box: MazeTileMapNode.TileBox, color: UIColor) {
        if let maze = self.maze {
            let node = SKSpriteNode(color: color, size: maze.tileBoxSize())
            node.position = maze.tileBoxCenter(box)
            node.zPosition = -10
            
            self.addChild(node)
            cutPathNodes.append(node)
        }
    }
    
    func resetCut() {
        if let maze = self.maze, cutPathNodes.count == 0 {
            let cutStart = MazeTileMapNode.TileBox(x: maze.random(boxMapWidth), y: maze.random(boxMapHeight))
            maze.cutStart(at: cutStart)
            drawBox(cutStart, color: .green)
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.0/60.0, target: self, selector: #selector(GameScene.cutMaze), userInfo: nil, repeats: true)
        }
    }
    
    func cutMaze() {
        if let box = maze?.cutStep() {
            drawBox(box, color: .green)
        }
        else if cutPathNodes.count > 0 {
            let removedBox = cutPathNodes.removeLast()
            removedBox.removeFromParent()
        }
        else {
            timer?.invalidate()
        }
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
