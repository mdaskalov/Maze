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
    private let boxSize = 3
    private let boxMapWidth = 41
    private let boxMapHeight = 31
    
    private var maze: MazeTileMapNode?
    private var touchPos: CGPoint?

    private var timer : Timer?
    private var cutPathNodes = Array<SKSpriteNode>()
    
    override func didMove(to view: SKView) {
        if let label = self.childNode(withName: "//readyLabel") as? SKLabelNode {
            label.run(SKAction.fadeOut(withDuration: 2.0))
        }
                
        let maze = MazeTileMapNode(columns: boxMapWidth, rows: boxMapHeight, boxSize: boxSize)
        
        self.camera?.setScale(21.0)
        self.addChild(maze)
        self.maze = maze
            
        self.maze = maze
        touchPos = maze.position
        
        resetCut()
    }
    
    func drawBox(_ box: MazeTileMapNode.TileBox, color: NSColor) {
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
    
    func touchDown(atPoint: CGPoint) {
        touchPos=convertPoint(fromView: atPoint)
    }
    
    func touchMoved(toPoint: CGPoint) {
        if let camera = self.camera, let touchPos = self.touchPos {
            let to = convertPoint(fromView: toPoint)
            let translation = CGPoint(x: touchPos.x - to.x, y: touchPos.y - to.y)
            
            camera.position.x += translation.x
            camera.position.y += translation.y
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    func zoom(delta: CGFloat) {
        if let camera = self.camera {
            camera.setScale(camera.xScale + delta / 10)
            if camera.xScale < 0.05 {
                camera.setScale(0.05)
            }
            
            if camera.xScale > 21 {
                camera.setScale(21)
            }
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
        case 15: // r
            resetCut()
        case 49: // space
            cutMaze()
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
