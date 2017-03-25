//
//  MazeSolver.swift
//  Maze
//
//  Created by Milko Daskalov on 16.03.17.
//  Copyright © 2017 Milko Daskalov. All rights reserved.
//

import SpriteKit

class MazeSolver {
    
    private let walkerFrames = 28;

    private let maze: MazeTileMapNode
    private let scene: SKScene
    
    private var start: MazeTileMapNode.TileBox
    
    private var startNode: SKSpriteNode
    private var endNode: SKSpriteNode
    
    private var animationNodes: [SKSpriteNode] = []

    private var pointType: PointType = .start

    enum PointType {
        case start
        case end
    }
    
    init(maze: MazeTileMapNode, scene: SKScene) {
        self.maze = maze
        self.scene = scene
        self.start = MazeTileMapNode.TileBox(x: 0, y: 0)
        self.startNode = SKSpriteNode()
        self.endNode = SKSpriteNode()
    }
    
    func animationTextures(baseName: String, count: Int) -> [SKTexture] {
        var result = [SKTexture]()
        for i in 1...count {
            let texture = SKTexture(imageNamed: String(format: "\(baseName)%04d",i))
            result.append(texture)
        }
        return result
    }
    
    private func setPoint(at: MazeTileMapNode.TileBox, type: PointType) -> SKSpriteNode {
        let node = SKSpriteNode(color: type == .start ? .red : .green, size: maze.tileBoxSize().applying(CGAffineTransform(scaleX: 0.6, y: 0.6)))
        node.name = "Solution.point"
        node.zPosition = -9
        node.position = maze.tileBoxCenter(at)
        self.scene.addChild(node)
        return node
    }
    
    private func animateSolution(_ solution: [MazeTileMapNode.TileBox], animateCamera: Bool) {
        
        if solution.count > 1 {
            let moveInterval = (animateCamera ? 0.5 : 0.2)
            let rotateInterval = moveInterval / 4
            let blinkCount = 1
            let blinkInterval = 0.20
            let fadeInInterval = 0.20
            let fadeOutInterval = 0.20
            let fadeOutAlpha: CGFloat = 0.2
            let actionDelay: TimeInterval = (moveInterval) * Double(solution.count)
            
            let textures = animationTextures(baseName: "warrior_walk_", count: walkerFrames)
            let moveNode = SKSpriteNode(texture: textures[0])

            let walkerAnimation = SKAction.repeatForever(
                SKAction.animate(with: textures, timePerFrame: 1.0/Double(walkerFrames))
                )
            
            let pathAnimation = SKAction.sequence([
                SKAction.wait(forDuration: actionDelay),
                SKAction.fadeOut(withDuration: fadeOutInterval),
                SKAction.removeFromParent()
                ])
            
            let blinkAnimation = SKAction.sequence([
                SKAction.repeat(SKAction.sequence([
                    SKAction.fadeIn(withDuration: blinkInterval),
                    SKAction.fadeOut(withDuration: blinkInterval)
                    ]), count: blinkCount),
                SKAction.fadeAlpha(to: fadeOutAlpha, duration: fadeInInterval)
                ])

            moveNode.name = "Solution.move"
            moveNode.zPosition = 5
            moveNode.xScale = 5
            moveNode.yScale = 5
            self.scene.addChild(moveNode)
            
            var moveAnimation = [SKAction]()
            var rotationAnimation = [SKAction]()
            
            for i in 0..<solution.count {
                let box = solution[i]
                let center = maze.tileBoxCenter(box)
                
                let pathNode = SKSpriteNode(color: .white, size: maze.tileBoxSize())
                pathNode.name = "Solution.path"
                pathNode.alpha = 0
                pathNode.position = center
                pathNode.zPosition = -10
                
                if i > 0 {
                    let startBox = solution[i-1]
                    let bearing = CGFloat(atan2(Double(startBox.x - box.x), Double(box.y-startBox.y)))
                    let move = SKAction.move(to: center, duration: moveInterval)
                    let rotate = SKAction.rotate(toAngle: bearing, duration: rotateInterval, shortestUnitArc:true)
                    moveAnimation.append(move)
                    rotationAnimation.append(rotate)
                    rotationAnimation.append(SKAction.wait(forDuration: moveInterval - rotateInterval))
                }
                else {
                    moveAnimation.append(SKAction.move(to: center, duration: 0))
                }
                
                pathNode.run(SKAction.group([blinkAnimation, pathAnimation]))
                self.scene.addChild(pathNode)
            }
            if animateCamera {
                self.scene.camera?.run(SKAction.sequence(moveAnimation))
            }
            startNode.run(SKAction.group([SKAction.repeatForever(SKAction.rotate(byAngle: 1, duration: fadeOutInterval)),pathAnimation]))
            endNode.run(SKAction.group([SKAction.repeatForever(SKAction.rotate(byAngle: -1, duration: fadeOutInterval)),pathAnimation]))
            moveAnimation.append(SKAction.removeFromParent())
            moveNode.run(SKAction.group([walkerAnimation,SKAction.sequence(rotationAnimation),SKAction.sequence(moveAnimation)]))
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
    
    func setPoint(at: MazeTileMapNode.TileBox) {
        switch pointType {
        case .start:
            abortSolving()
            self.start = at
            self.startNode = setPoint(at: at, type: .start)
            pointType = .end
        case .end:
            self.endNode = setPoint(at: at, type: .end)
            animateSolution(maze.findSolution(from: self.start, to: at), animateCamera: false)
            pointType = .start
        }
    }
    
    func solveMaze(start: MazeTileMapNode.TileBox, end: MazeTileMapNode.TileBox, animateCamera: Bool=false) {
        abortSolving()
        self.startNode = setPoint(at: start, type: .start)
        self.endNode = setPoint(at: end, type: .end)
        animateSolution(maze.findSolution(from: start, to: end), animateCamera: animateCamera)
    }

}
