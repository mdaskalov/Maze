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
    private let boxSize = 2
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
    
    func tap(at: CGPoint) {
        //print("tap")
        
        if let maze = self.maze, let mazeSolver = self.mazeSolver, let clickBox = maze.tileBox(fromPosition: self.convertPoint(fromView: at)) {
            //print(String(format: "click at: %03d,%03d", clickBox.x, clickBox.y))
            mazeSolver.setPoint(at: clickBox)
        }
    }
    
    func doubleTap() {
        //print("doubleTap")
        
        if let maze = self.maze, let mazeSolver = self.mazeSolver {
            mazeSolver.solveMaze(start: maze.randomTileBox(), end: maze.randomTileBox(), animateCamera: true)
        }
    }
    
    func longPress() {
        mazeSolver?.abortSolving()
        resetCut()
        //maze?.cutMaze()
    }
    
    func panBegan(location: CGPoint, translation: CGPoint, velocity: CGPoint) {
        touchPos=location

        //print(String(format: "  began Pan loc: %4.2f,%4.2f tra: %4.2f,%4.2f vel: %4.2f,%4.2f", location.x,location.y,translation.x,translation.y,velocity.x,velocity.y))
    }
    
    func panChanged(location: CGPoint, translation: CGPoint, velocity: CGPoint) {
        
        if let camera = self.camera, let touchPos = self.touchPos {
            let translation = CGPoint(x: touchPos.x - location.x, y: touchPos.y - location.y)
            
            camera.position.x += (translation.x * (camera.xScale))
            camera.position.y += (translation.y * (camera.yScale))
            
            self.touchPos = location
        }

        /*
        camera!.position.x += (translation.x * (camera!.xScale / 10))
        camera!.position.y += (translation.y * (camera!.yScale / 10))
        */
        //print(String(format: "changed Pan loc: %4.2f,%4.2f tra: %4.2f,%4.2f vel: %4.2f,%4.2f", location.x,location.y,translation.x,translation.y,velocity.x,velocity.y))
    }
    
    func panEnded(location: CGPoint, translation: CGPoint, velocity: CGPoint) {
        if abs(translation.x) < 0.5 && abs(translation.y) < 0.5 {
            tap(at: location)
            return
        }
        //print(String(format: "  ended Pan loc: %4.2f,%4.2f tra: %4.2f,%4.2f vel: %4.2f,%4.2f", location.x,location.y,translation.x,translation.y,velocity.x,velocity.y))
    }
    
    func zoom(delta: CGFloat) {
        if let camera = self.camera {
            var scale = camera.xScale + delta / 10
            if scale < 0.8 {
                scale = 0.8
            }
            if scale > initialZoom {
                scale = initialZoom
            }
            camera.setScale(scale)
            //print(String(format: "zoom: %.2f", camera.xScale))
        }
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
