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
    
    let boxSize = 2
    let boxMapSize = 20
    let cameraScale: CGFloat = -35.0
    
    private var maze: MazeTileMapNode?
    private var touchPos: CGPoint?
    
    private var timer : Timer?
    private var cutPathNodes = Array<SKSpriteNode>()
    
    override func sceneDidLoad() {
        if let label = self.childNode(withName: "//readyLabel") as? SKLabelNode {
            label.xScale = cameraScale
            label.yScale = cameraScale
            label.run(SKAction.sequence([SKAction.fadeOut(withDuration: 2.0),SKAction.removeFromParent()]))
        }
        
        let maze = MazeTileMapNode(columns: boxMapSize, rows: boxMapSize, boxSize: boxSize, groupName: "Grass")
        
        maze.position.x = 0
        maze.position.y = 0
        
        self.camera?.setScale(cameraScale)
        self.addChild(maze)
        self.maze = maze
        
        self.maze = maze
        touchPos = maze.position
        
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
            let cutStart = MazeTileMapNode.TileBox(x: maze.random(boxMapSize), y: maze.random(boxMapSize))
            maze.cutStart(at: cutStart)
            drawBox(cutStart, color: .blue)
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.0/60.0, target: self, selector: #selector(GameScene.cutMaze), userInfo: nil, repeats: true)
        }
    }
    
    @objc func cutMaze() {
        if let box = maze?.cutStep() {
            drawBox(box, color: .blue)
        }
        else if cutPathNodes.count > 0 {
            let removedBox = cutPathNodes.removeLast()
            removedBox.removeFromParent()
        }
        else {
            timer?.invalidate()
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        touchPos=pos
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if (touchPos != nil) {
            let moveBy = CGVector(dx: touchPos!.x - pos.x, dy: touchPos!.y - pos.y)
            //let moveDir = CGFloat(atan2f(Float(moveBy.dx),Float(-moveBy.dy)))
            camera?.position.x += (moveBy.dx * camera!.xScale * 1.5)
            camera?.position.y += (moveBy.dy * camera!.xScale * 1.5)
            touchPos = pos
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    func zoom(by: CGFloat) {
        camera?.xScale = -by * 5
        camera?.yScale = -by * 5
        //print("scale: \(camera!.xScale)")
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
