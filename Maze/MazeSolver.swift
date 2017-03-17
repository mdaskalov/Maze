//
//  MazeSolver.swift
//  Maze
//
//  Created by Milko Daskalov on 16.03.17.
//  Copyright © 2017 Milko Daskalov. All rights reserved.
//

import SpriteKit
import GameplayKit

class MazeSolver {
    
    private let boxMapWidth: Int
    private let boxMapHeight: Int
    private let maze: MazeTileMapNode
    private let scene: SKScene
    
    private var animationNodes: [SKSpriteNode] = []

    init(maze: MazeTileMapNode, width: Int, height: Int, scene: SKScene) {
        self.maze = maze
        self.boxMapWidth = width
        self.boxMapHeight = height
        self.scene = scene
    }
    
    func animateSolution(_ solution: [GKGridGraphNode], animateCamera: Bool) {
        
        if solution.count > 1 {
            
            let moveInterval = (animateCamera ? 0.5 : 0.1)
            let blinkCount = 1
            let blinkInterval = 0.2
            let fadeInInterval = 0.15
            let fadeOutInterval = 0.15
            let actionDelay: TimeInterval = (moveInterval) * Double(solution.count)
            
            let startPosition = maze.tileBoxCenter(MazeTileMapNode.TileBox(x: Int(solution[0].gridPosition.x), y: Int(solution[0].gridPosition.y)))
            let endPosition = maze.tileBoxCenter(MazeTileMapNode.TileBox(x: Int(solution[solution.count-1].gridPosition.x), y: Int(solution[solution.count-1].gridPosition.y)))
            
            let size = maze.tileBoxSize()
            
            let moveNode = SKSpriteNode(imageNamed: "Spaceship") //SKSpriteNode(color: .yellow, size: size.applying(CGAffineTransform(scaleX: 0.5, y: 0.5)))
            moveNode.name = "Solution.move"
            moveNode.zPosition = 5
            self.scene.addChild(moveNode)
            
            let pathAnimation = SKAction.sequence([
                SKAction.wait(forDuration: actionDelay - fadeOutInterval),
                SKAction.fadeOut(withDuration: fadeOutInterval),
                SKAction.removeFromParent()
            ])
            
            let start = SKSpriteNode(color: .red, size: size.applying(CGAffineTransform(scaleX: 0.6, y: 0.6)))
            start.name = "Solution.start"
            start.position = startPosition
            start.zPosition = -9
            start.run(pathAnimation)
            self.scene.addChild(start)
            
            let end = SKSpriteNode(color: .green, size: size.applying(CGAffineTransform(scaleX: 0.6, y: 0.6)))
            end.name = "Solution.end"
            end.position = endPosition
            end.zPosition = -9
            end.run(pathAnimation)
            self.scene.addChild(end)
            
            var moveAnimation = [SKAction]()
            var cameraAnimation = [SKAction]()
            
            for i in 0..<solution.count {
                let box = MazeTileMapNode.TileBox(x: Int(solution[i].gridPosition.x), y: Int(solution[i].gridPosition.y))
                let center = maze.tileBoxCenter(box)
                
                let node = SKSpriteNode(color: .white, size: size)
                node.name = "Solution.box"
                node.alpha = 0
                node.position = center
                node.zPosition = -10
                
                if i > 0 {
                    let startBox = MazeTileMapNode.TileBox(x: Int(solution[i-1].gridPosition.x), y: Int(solution[i-1].gridPosition.y))
                    let startCenter = maze.tileBoxCenter(startBox)
                    
                    let bearing = CGFloat(atan2f(Float(startCenter.x - center.x), Float(center.y-startCenter.y)))
                    let move = SKAction.move(to: center, duration: moveInterval)
                    let rotate = SKAction.rotate(toAngle: bearing, duration: moveInterval/8, shortestUnitArc:true)
                    moveAnimation.append(SKAction.group([rotate,move]))
                    cameraAnimation.append(move)
                }
                else {
                    moveAnimation.append(SKAction.move(to: center, duration: 0))
                    cameraAnimation.append(SKAction.move(to: center, duration: 0))
                }
                
                let blinkAnimation = SKAction.sequence([
                    SKAction.repeat(SKAction.sequence([
                        SKAction.fadeIn(withDuration: blinkInterval),
                        SKAction.fadeOut(withDuration: blinkInterval)
                    ]), count: blinkCount),
                    SKAction.fadeAlpha(to: 0.2, duration: fadeInInterval)
                ])
                node.run(SKAction.group([blinkAnimation, pathAnimation]))
                self.scene.addChild(node)
            }
            if animateCamera {
                self.scene.camera?.run(SKAction.sequence(cameraAnimation))
            }
            moveAnimation.append(SKAction.removeFromParent())
            moveNode.run(SKAction.sequence(moveAnimation))
        }
    }
    
    func abortSolving() {
        scene.enumerateChildNodes(withName: "Solution*", using: {
            (node, stop) in
            node.removeAllActions()
            node.removeFromParent()
        })
        scene.camera?.removeAllActions()
    }
    
    func solveMaze(animateCamera: Bool=false) {
        abortSolving()
        let startNode = maze.mazeGraph.node(atGridPosition: (vector_int2)(Int32(maze.random(boxMapWidth)),Int32(maze.random(boxMapHeight))))
        let endNode = maze.mazeGraph.node(atGridPosition: (vector_int2)(Int32(maze.random(boxMapWidth)),Int32(maze.random(boxMapHeight))))
        
        if startNode != nil && endNode != nil {
            let solution = maze.mazeGraph.findPath(from: startNode!, to: endNode!) as! [GKGridGraphNode]
            if !solution.isEmpty {
                animateSolution(solution, animateCamera: animateCamera)
            }
        }
    }

}
