//
//  MazeTileMapNode.swift
//  Maze
//
//  Created by Milko Daskalov on 05.03.17.
//  Copyright © 2017 Milko Daskalov. All rights reserved.
//

import Cocoa
import SpriteKit

class MazeTileMapNode: SKTileMapNode {
    
    private var columns: Int
    private var rows: Int
    private var boxSize: Int
    private var group: String
    
    enum Direction: Int {
        case Left   = 0
        case Right  = 1
        case Up     = 2
        case Down   = 3
    }
    
    enum TileType {
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
    
    init(columns: Int, rows: Int, boxSize: Int, tileSetName: String = "MazeGridTileSet", groupName: String = "Cobblestone") {
        self.columns = columns
        self.rows = rows
        self.boxSize = boxSize
        self.group = groupName
        
        super.init()
        
        if let tileSet = SKTileSet(named: tileSetName) {
            self.tileSet = tileSet
            numberOfColumns = columns*(boxSize+1)
            numberOfRows = rows*(boxSize+1)
            tileSize = CGSize(width: 128, height: 128)
            enableAutomapping = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.columns = 0
        self.rows = 0
        self.boxSize = 3
        self.group = ""
        super.init(coder: aDecoder)
    }
    
    private func setTile(type: TileType, column: Int, row: Int, group: String = "") {
        var rule:String = ""
        var tile: String = ""
        let groupPrefix = group=="" ? self.group : group
        let tilePrefix = groupPrefix + "_Grid_"
        
        switch type {
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
            rule = "Upper Left Corner"
            tile = "UpLeftInterior"
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
    
    func drawTileBox(column: Int, row: Int, group: String = "") {
        let tileColumn = column*(boxSize+1)
        let tileRow = row*(boxSize+1)
        setTile(type: .UpperLeftCorner, column: tileColumn, row: tileRow+boxSize, group: group)
        setTile(type: .UpperRightCorner, column: tileColumn+boxSize, row: tileRow+boxSize, group: group)
        for c in tileColumn+1...tileColumn+boxSize-1 {
            setTile(type: .DownEdge, column: c, row: tileRow+boxSize, group: group)
            setTile(type: .UpEdge, column: c, row: tileRow, group: group)
        }
        for r in tileRow+1...tileRow+boxSize-1 {
            setTile(type: .RightEdge, column: tileColumn, row: r, group: group)
            setTile(type: .LeftEdge, column: tileColumn+boxSize, row: r, group: group)
        }
        setTile(type: .LowerLeftCorner, column: tileColumn, row: tileRow, group: group)
        setTile(type: .LowerRightCorner, column: tileColumn+boxSize, row: tileRow, group: group)
    }
    
    func cutTileBox(side: Direction, column: Int, row: Int) {
        let tileColumn = column*(boxSize+1)
        let tileRow = row*(boxSize+1)

        switch side {
        case .Up, .Down:
            if tileRow < 0 || tileRow+boxSize >= numberOfRows {
                break
            }
            let r1 = (side == .Up ? tileRow+boxSize : tileRow)
            let r2 = (side == .Up ? tileRow+boxSize+1 : tileRow-1)
            setTile(type: .RightEdge, column: tileColumn, row: r1)
            setTile(type: .RightEdge, column: tileColumn, row: r2)
            for c in tileColumn+1...tileColumn+boxSize-1 {
                setTileGroup(nil, forColumn: c, row: r1)
                setTileGroup(nil, forColumn: c, row: r2)
            }
            setTile(type: .LeftEdge, column: tileColumn+boxSize, row: r1)
            setTile(type: .LeftEdge, column: tileColumn+boxSize, row: r2)
        case .Left, .Right:
            if tileColumn < 0 || tileColumn+boxSize >= numberOfColumns {
                break
            }
            let c1 = (side == .Left ? tileColumn : tileColumn+boxSize)
            let c2 = (side == .Left ? tileColumn-1 : tileColumn+boxSize+1)
            setTile(type: .UpEdge, column: c1, row: tileRow)
            setTile(type: .UpEdge, column: c2, row: tileRow)
            for r in tileRow+1...tileRow+boxSize-1 {
                setTileGroup(nil, forColumn: c1, row: r)
                setTileGroup(nil, forColumn: c2, row: r)
            }
            setTile(type: .DownEdge, column: c1, row: tileRow+boxSize)
            setTile(type: .DownEdge, column: c2, row: tileRow+boxSize)
        }
    }
    
    func cutMaze() {
        var isCut = Array(repeating: Array<Bool>(repeating: false, count: columns), count: rows)
        var cutPath = Array<(x: Int, y:Int)>(repeating: (x: 0, y: 0), count: 5000)
        
        assert(rows>2 && columns>2)
        
        var dir: Direction
        var x = 0
        var y = 0
        var cutPos = 0
        isCut[x][y] = true
        cutPath[cutPos] = (x: x, y: y)
        
        for c in 0..<columns {
            for r in 0..<rows {
                drawTileBox(column: c, row: r)
            }
        }

        repeat {
            if (x > 1 && !isCut[x-1][y]) || (x < columns-1 && !isCut[x+1][y]) ||
                (y > 1 && !isCut[x][y-1]) || (y < rows-1  && !isCut[x][y+1]) {
                let ox = x
                let oy = y
                repeat {
                    x = ox
                    y = oy
                    dir = Direction(rawValue: Int(arc4random_uniform(4)))!
                    switch dir {
                    case .Left:  x -= 1
                    case .Right: x += 1
                    case .Up:    y += 1
                    case .Down:  y -= 1
                    }
                } while x < 0 || x >= columns || y < 0 || y >= rows || isCut[x][y]
                isCut[x][y] = true
                cutPos += 1
                cutPath[cutPos] = (x: x, y: y)
                cutTileBox(side: dir, column: ox, row: oy)
                print("move \(cutPos) from: \(ox),\(oy) \(dir) to: \(x),\(y)")
            }
            else {
                cutPos -= 1
                x = cutPath[cutPos].x
                y = cutPath[cutPos].y
                print("back to move \(cutPos) (\(x),\(y))")
            }
        } while cutPos > 0
    }
}
