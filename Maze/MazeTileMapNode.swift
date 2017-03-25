//
//  MazeTileMapNode.swift
//  Maze
//
//  Created by Milko Daskalov on 05.03.17.
//  Copyright © 2017 Milko Daskalov. All rights reserved.
//

import SpriteKit
#if os(iOS) || os(macOS)
import GameplayKit
#endif

class MazeTileMapNode: SKTileMapNode {
    
    private var columns: Int
    private var rows: Int
    private var boxSize: Int
    private var group: String
    private var processed: [[Bool]]
    
    private var cutPath = Array<MazeTileMapNode.TileBox>()
    private var cutBox = TileBox(x: 0, y: 0)
    
    #if os(iOS) || os(macOS)
    private var mazeGraph: GKGridGraph<GKGridGraphNode>
    #endif
    
    struct TileBox {
        var x: Int
        var y: Int
    }
    
    enum Direction: Int {
        case Left   = 0
        case Right  = 1
        case Up     = 2
        case Down   = 3
    }
    
    enum TileType {
        case None
        case Center
        case UpEdge
        case UpperRightEdge
        case RightEdge
        case LowerRightEdge
        case DownEdge
        case LowerLeftEdge
        case LeftEdge
        case UpperLeftEdge
        case UpperRightCorner
        case LowerRightCorner
        case LowerLeftCorner
        case UpperLeftCorner
    }
    
    init(columns: Int, rows: Int, boxSize: Int, groupName: String = "Cobblestone", tileSetName: String = "MazeGridTileSet") {
        self.columns = columns
        self.rows = rows
        self.boxSize = boxSize
        self.group = groupName
        self.processed = Array(repeating: Array<Bool>(repeating: false, count: rows), count: columns)
        
        #if os(iOS) || os(macOS)
        self.mazeGraph = GKGridGraph<GKGridGraphNode>(fromGridStartingAt: vector_int2(0,0), width: Int32(columns), height: Int32(rows), diagonalsAllowed: false)
        for node in self.mazeGraph.nodes! {
            node.removeConnections(to: node.connectedNodes, bidirectional: true)
        }
        #endif
        
        super.init()
        
        if let tileSet = SKTileSet(named: tileSetName) {
            self.tileSet = tileSet
            numberOfColumns = columns*(boxSize+2)
            numberOfRows = rows*(boxSize+2)
            tileSize = CGSize(width: 128, height: 128)
            enableAutomapping = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    private func setTile(type: TileType, column: Int, row: Int, group: String = "") {
        var rule:String = ""
        var tile: String = ""
        let groupPrefix = group=="" ? self.group : group
        let tilePrefix = groupPrefix + "_Grid_"
        
        switch type {
        case .None:
            setTileGroup(nil, forColumn: column, row: row)
            return
        case .Center:
            rule = "Center"
            tile = "Center"
        case .UpEdge:
            rule = "Up Edge"
            tile = "Up"
        case .UpperRightEdge:
            rule = "Upper Right Edge"
            tile = "UpRight"
        case .RightEdge:
            rule = "Right Edge"
            tile = "Right"
        case .LowerRightEdge:
            rule = "Lower Right Edge"
            tile = "DownRight"
        case .DownEdge:
            rule = "Down Edge"
            tile = "Down"
        case .LowerLeftEdge:
            rule = "Lower Left Edge"
            tile = "DownLeft"
        case .LeftEdge:
            rule = "Left Edge"
            tile = "Left"
        case .UpperLeftEdge:
            rule = "Upper Left Edge"
            tile = "UpLeft"
        case .UpperRightCorner:
            rule = "Upper Right Corner"
            tile = "UpRightInterior"
        case .LowerRightCorner:
            rule = "Lower Right Corner"
            tile = "DownRightInterior"
        case .LowerLeftCorner:
            rule = "Lower Left Corner"
            tile = "DownLeftInterior"
        case .UpperLeftCorner:
            rule = "Upper Left Corner"
            tile = "UpLeftInterior"
        }
        
        if let tileGroup = self.tileSet.tileGroups.first(where: {$0.name == groupPrefix}) {
            if let tileDefinition = tileGroup.rules.first(where: {$0.name == rule})?.tileDefinitions.first(where: {$0.name == tilePrefix+tile}) {
                setTileGroup(tileGroup, andTileDefinition: tileDefinition, forColumn: column, row: row)
            }
        }
    }
    
    func random(_ max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max)))
    }
    
    func randomTileBox() -> TileBox {
        return TileBox(x: random(columns), y: random(rows))
    }
    
    func tileBox(fromPosition: CGPoint) -> TileBox? {
        let tileColumn = tileColumnIndex(fromPosition: fromPosition)
        let tileRow = tileRowIndex(fromPosition: fromPosition)
        let box = TileBox(x: tileColumn / (boxSize+2), y: tileRow / (boxSize+2))
        return isInBounds(box) ? box : nil
    }
    
    func tileBoxCenter(_ box: MazeTileMapNode.TileBox) -> CGPoint  {
        let tileColumn = box.x*(self.boxSize+2)
        let tileRow = box.y*(self.boxSize+2)
        
        let boxSize = self.tileBoxSize()
        let center = centerOfTile(atColumn: tileColumn, row: tileRow)
        
        let translation = CGAffineTransform(translationX: -tileSize.width/2, y: -tileSize.height/2).translatedBy(x: boxSize.width/2, y: boxSize.height/2)
        
        return center.applying(translation)
    }

    func tileBoxSize() -> CGSize {
        return tileSize.applying(CGAffineTransform(scaleX: CGFloat(self.boxSize+2), y: CGFloat(self.boxSize+2)))
    }
    
    func drawTileBox(_ box: TileBox, group: String = "") {
        let tileColumn = box.x*(boxSize+2)
        let tileRow = box.y*(boxSize+2)
        setTile(type: .UpperLeftCorner, column: tileColumn, row: tileRow+boxSize+1, group: group)
        setTile(type: .UpperRightCorner, column: tileColumn+boxSize+1, row: tileRow+boxSize+1, group: group)
        for c in tileColumn+1...tileColumn+boxSize {
            setTile(type: .DownEdge, column: c, row: tileRow+boxSize+1, group: group)
            setTile(type: .UpEdge, column: c, row: tileRow, group: group)
        }
        for r in tileRow+1...tileRow+boxSize {
            setTile(type: .RightEdge, column: tileColumn, row: r, group: group)
            setTile(type: .LeftEdge, column: tileColumn+boxSize+1, row: r, group: group)
        }
        setTile(type: .LowerLeftCorner, column: tileColumn, row: tileRow, group: group)
        setTile(type: .LowerRightCorner, column: tileColumn+boxSize+1, row: tileRow, group: group)
    }
    
    func checkTileBox(side: Direction, column: Int, row: Int) -> Bool {
        var tileColumn = column*(boxSize+2)
        var tileRow = row*(boxSize+2)
        
        if tileRow < 0 || tileRow+boxSize+1 >= numberOfRows || tileColumn < 0 || tileColumn+boxSize+1 >= numberOfColumns {
            return true
        }
        
        switch side {
        case .Left:
            tileRow += 1
        case .Right:
            tileColumn += boxSize+1
            tileRow += 1
        case .Up:
            tileColumn += 1
            tileRow += boxSize+1
        case .Down:
            tileColumn += 1
        }
        
        return (tileGroup(atColumn: tileColumn, row: tileRow) != nil)
    }
    
    func cutTileBox(_ box: TileBox, side: Direction) {
        let tileColumn = box.x*(boxSize+2)
        let tileRow = box.y*(boxSize+2)
        
        if !isInBounds(box) {
            return
        }
        
        #if os(iOS) || os(macOS)
        if let oppositeBox = boxAt(side, from: box),
            let node = mazeGraph.node(atGridPosition: (vector_int2)(Int32(box.x),Int32(box.y))),
            let oppositeNode = mazeGraph.node(atGridPosition: (vector_int2)(Int32(oppositeBox.x),Int32(oppositeBox.y))) {
            node.addConnections(to: [oppositeNode], bidirectional: true)
        }
        #endif
        
        switch side {
        case .Up, .Down:
            if (side == .Down && tileRow < 0) || (side == .Up && tileRow+boxSize+2 >= numberOfRows) {
                break
            }
            
            let leftSide = checkTileBox(side: .Left, column: box.x, row: box.y)
            let leftSideOutside = checkTileBox(side: .Left, column: box.x, row: (side == .Up ? box.y+1 : box.y-1))
            let rightSide = checkTileBox(side: .Right, column: box.x, row: box.y)
            let rightSideOutside = checkTileBox(side: .Right, column: box.x, row: (side == .Up ? box.y+1 : box.y-1))
            
            let outsideEdgeRow = (side == .Up ? tileRow+boxSize+2 : tileRow-1)
            let insideEdgeRow = (side == .Up ? tileRow+boxSize+1 : tileRow)
            
            let leftEdgeInsideNoWall: TileType = (side == .Up ? .LowerRightEdge : .UpperRightEdge)
            let leftEdgeOutsideNoWall: TileType = (side == .Up ? .UpperRightEdge : .LowerRightEdge)
            let rightEdgeInsideNoWall: TileType = (side == .Up ? .LowerLeftEdge : .UpperLeftEdge)
            let rightEdgeOutsideNoWall: TileType = (side == .Up ? .UpperLeftEdge : .LowerLeftEdge)
            
            //Left
            setTile(type: leftSide ? .RightEdge : leftEdgeInsideNoWall, column: tileColumn, row: insideEdgeRow)
            setTile(type: leftSideOutside ? .RightEdge : leftEdgeOutsideNoWall, column: tileColumn, row: outsideEdgeRow)
            //Center
            for c in tileColumn+1...tileColumn+boxSize {
                setTile(type: .None, column: c, row: insideEdgeRow)
                setTile(type: .None, column: c, row: outsideEdgeRow)
            }
            //Right
            setTile(type: rightSide ? .LeftEdge : rightEdgeInsideNoWall, column: tileColumn+boxSize+1, row: insideEdgeRow)
            setTile(type: rightSideOutside ? .LeftEdge : rightEdgeOutsideNoWall, column: tileColumn+boxSize+1, row: outsideEdgeRow)
        case .Left, .Right:
            if (side == .Left && tileColumn < 0) || (side == .Right && tileColumn+boxSize+2 >= numberOfColumns) {
                break
            }
            
            let upSide = checkTileBox(side: .Up, column: box.x, row: box.y)
            let upSideOutside = checkTileBox(side: .Up, column: (side == .Left ? box.x-1 : box.x+1), row: box.y)
            let downSide = checkTileBox(side: .Down, column: box.x, row: box.y)
            let downSideOutside = checkTileBox(side: .Down, column: (side == .Left ? box.x-1 : box.x+1), row: box.y)

            let outsideEdgeColumn = (side == .Left ? tileColumn-1 : tileColumn+boxSize+2)
            let insideEdgeColumn = (side == .Left ? tileColumn : tileColumn+boxSize+1)

            let upEdgeInsideNoWall: TileType = (side == .Left ? .LowerRightEdge : .LowerLeftEdge)
            let upEdgeOutsideNoWall: TileType = (side == .Left ? .LowerLeftEdge : .LowerRightEdge)
            let downEdgeInsideNoWall: TileType = (side == .Left ? .UpperRightEdge : .UpperLeftEdge)
            let downEdgeOutsideNoWall: TileType = (side == .Left ? .UpperLeftEdge : .UpperRightEdge)

            //Up
            setTile(type: upSide ? .DownEdge : upEdgeInsideNoWall, column: insideEdgeColumn, row: tileRow+boxSize+1)
            setTile(type: upSideOutside ? .DownEdge : upEdgeOutsideNoWall,  column: outsideEdgeColumn, row: tileRow+boxSize+1)
            //Center
            for r in tileRow+1...tileRow+boxSize {
                setTile(type: .None, column: insideEdgeColumn, row: r)
                setTile(type: .None, column: outsideEdgeColumn, row: r)
            }
            //Down
            setTile(type: downSide ? .UpEdge : downEdgeInsideNoWall, column: insideEdgeColumn, row: tileRow)
            setTile(type: downSideOutside ? .UpEdge : downEdgeOutsideNoWall, column: outsideEdgeColumn, row: tileRow)
        }
    }
    
    func isInBounds(_ box: TileBox) -> Bool {
        return box.x >= 0 && box.x < columns && box.y >= 0 && box.y < rows
    }
    
    func boxAt(_ direction: Direction, from: TileBox) -> TileBox? {
        var box = from
        
        switch direction {
        case .Left:  box.x -= 1
        case .Right: box.x += 1
        case .Up:    box.y += 1
        case .Down:  box.y -= 1
        }
        
        return isInBounds(box) ? box : nil
    }
    
    func emptyBoxAt(_ direction: Direction, from: TileBox) -> TileBox? {
        let box = boxAt(direction, from: from)
        let boxIsProcessed = (box == nil || processed[box!.x][box!.y])
        return boxIsProcessed ? nil : box
    }
    
    func findEmptyNeighbour(_ box: TileBox) -> (box: TileBox, at: Direction)? {
        if !isInBounds(box) {
            return nil
        }
        
        processed[box.x][box.y] = true

        let boxAtLeft = emptyBoxAt(.Left, from: box)
        let boxAtRight = emptyBoxAt(.Right, from: box)
        let boxAtUp = emptyBoxAt(.Up, from: box)
        let boxAtDown = emptyBoxAt(.Down, from: box)
        if boxAtLeft != nil || boxAtRight != nil || boxAtUp != nil || boxAtDown != nil {
            var dir: Direction
            var neighbour: TileBox?
            repeat {
                dir = Direction(rawValue: random(4))!
                neighbour = emptyBoxAt(dir, from: box)
            } while neighbour == nil
            return (box: neighbour!, at: dir)
        }
        else {
            return nil
        }
    }
    
    func cutStart(at: TileBox) {
        cutPath.removeAll()
        #if os(iOS) || os(macOS)
        for node in self.mazeGraph.nodes! {
            node.removeConnections(to: node.connectedNodes, bidirectional: true)
        }
        #endif
        for x in 0..<columns {
            for y in 0..<rows {
                drawTileBox(TileBox(x: x, y: y))
                processed[x][y] = false
            }
        }
        cutBox = at
    }
    
    func cutStep() -> TileBox? {
        if let neighbour = findEmptyNeighbour(cutBox) {
            //print("move \(cutPath.count+1) from: \(cutBox.x),\(cutBox.y) \(neighbour.at) to: \(neighbour.box.x),\(neighbour.box.y)")
            
            cutTileBox(cutBox, side: neighbour.at)
            
            cutPath.append(cutBox)
            cutBox = neighbour.box
            return cutBox
        }
        else if cutPath.count > 0 {
            cutBox = cutPath.removeLast()
            //print("back to move \(cutPath.count+1) (\(cutBox.x),\(cutBox.y))")
        }
        return nil
    }
    
    func cutReady() -> Bool {
        return cutPath.count == 0
    }
    
    func cutMaze() {
        cutStart(at: TileBox(x: 0, y: 0))
        repeat {
            let _ = cutStep()
        } while !cutReady()
    }
    
    func findSolution(from: TileBox, to: TileBox) -> [TileBox] {
        var result = [TileBox]()
        
        #if os(iOS) || os(macOS)
        let startNode = mazeGraph.node(atGridPosition: (vector_int2)(Int32(from.x),Int32(from.y)))
        let endNode = mazeGraph.node(atGridPosition: (vector_int2)(Int32(to.x),Int32(to.y)))
        
        if startNode != nil && endNode != nil {
            let path = mazeGraph.findPath(from: startNode!, to: endNode!) as! [GKGridGraphNode]
            for node in path {
                result.append(TileBox(x: Int(node.gridPosition.x), y: Int(node.gridPosition.y)))
            }
        }
        #endif
        
        return result
    }
}
