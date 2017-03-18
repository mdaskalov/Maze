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
    private let boxMapWidth = 41 //41
    private let boxMapHeight = 31 //31
    private let initialZoom: CGFloat = 21.0 // 21.0
    
    private var maze: MazeTileMapNode?
    private var touchPos: CGPoint?

    private var timer : Timer?
    private var cutPathNodes: [SKSpriteNode] = []
    
    private var mazeSolver: MazeSolver?
    
    private var startBox: MazeTileMapNode.TileBox = MazeTileMapNode.TileBox(x: 0, y: 0)
    
    override func didMove(to view: SKView) {
        let maze = MazeTileMapNode(columns: boxMapWidth, rows: boxMapHeight, boxSize: boxSize)
        
        self.camera?.setScale(initialZoom)
        self.addChild(maze)
        self.maze = maze
        
        self.mazeSolver = MazeSolver(maze: maze, scene: self)
        
        //resetCut()
        maze.cutMaze()

        touchPos = maze.position
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
            cutPathNodes.removeAll()
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
        touchPos=atPoint
        
        if let maze = self.maze, let mazeSolver = self.mazeSolver {
            if let clickBox = maze.tileBox(fromPosition: self.convertPoint(fromView: atPoint)) {
                mazeSolver.setPoint(at: clickBox)
                print(String(format: "click at: %03d,%03d", clickBox.x, clickBox.y))
            }
        }
        //print(String(format: "  began Pan loc: %4.2f,%4.2f", self.touchPos!.x,self.touchPos!.y))
    }
    
    func touchMoved(toPoint: CGPoint) {
        if let camera = self.camera, let touchPos = self.touchPos {
            let translation = CGPoint(x: touchPos.x - toPoint.x, y: touchPos.y - toPoint.y)
            
            camera.position.x += (translation.x * (camera.xScale))
            camera.position.y += (translation.y * (camera.yScale))
            
            self.touchPos = toPoint
            //print(String(format: "changed Pan loc: %4.2f,%4.2f", self.touchPos!.x,self.touchPos!.y))
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    func zoom(delta: CGFloat) {
        if let camera = self.camera {
            var scale = camera.xScale + delta / 10
            if scale < 0.8 {
                scale = 0.8
            }
            if scale > 25 {
                scale = 25
            }
            camera.setScale(scale)
            //print(String(format: "zoom: %.2f", camera.xScale))
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.locationInWindow)
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.locationInWindow)
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.locationInWindow)
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.characters! {
        case "s":
            if let maze = self.maze, let mazeSolver = self.mazeSolver {
                mazeSolver.solveMaze(start: maze.randomTileBox(), end: maze.randomTileBox())
            }
        case "c":
            if let maze = self.maze, let mazeSolver = self.mazeSolver {
                mazeSolver.solveMaze(start: maze.randomTileBox(), end: maze.randomTileBox(), animateCamera: true)
            }
        case "r": // reset
            mazeSolver?.abortSolving()
            resetCut()
        case " ": // cut
            timer?.invalidate()
            cutMaze()
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
