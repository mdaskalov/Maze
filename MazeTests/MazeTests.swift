//
//  MazeTests.swift
//  MazeTests
//
//  Created by Mike Daskaloff on 05.03.17.
//  Copyright © 2017 Milko Daskalov. All rights reserved.
//

import XCTest
@testable import Maze

class MazeTests: XCTestCase {
    let columns = 10
    let rows = 10
    let boxSize = 1
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func reset(_ maze: MazeTileMapNode) {
        for x in 0..<columns {
            for y in 0..<rows {
                maze.drawTileBox(MazeTileMapNode.TileBox(x: x, y: y))
            }
        }
    }
    
    func testInBounds() {
        let maze: MazeTileMapNode = MazeTileMapNode(columns: columns, rows: rows, boxSize: boxSize)
        
        XCTAssert(maze.isInBounds(MazeTileMapNode.TileBox(x: 0, y:  0)), "isInBounds true for 0, 0")
        
        XCTAssert(!maze.isInBounds(MazeTileMapNode.TileBox(x: -1, y:  0)), "isInBounds false for -1, 0")
        XCTAssert(!maze.isInBounds(MazeTileMapNode.TileBox(x:  0, y: -1)), "isInBounds false for  0,-1")
        XCTAssert(!maze.isInBounds(MazeTileMapNode.TileBox(x: -1, y: -1)), "isInBounds false for -1,-1")
        
        XCTAssert(!maze.isInBounds(MazeTileMapNode.TileBox(x: columns,   y: rows-1)), "isInBounds false for columns  ,rows-1")
        XCTAssert(!maze.isInBounds(MazeTileMapNode.TileBox(x: columns-1, y: rows  )), "isInBounds false for columns-1,rows")
        XCTAssert(!maze.isInBounds(MazeTileMapNode.TileBox(x: columns,   y: rows  )), "isInBounds false for columns  ,rows")
        
    }
    
    func testHorizontalCut() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let maze: MazeTileMapNode = MazeTileMapNode(columns: columns, rows: rows, boxSize: boxSize)
        reset(maze)
        
        maze.cutTileBox(MazeTileMapNode.TileBox(x: 0, y: 0), side: .Up)
        maze.cutTileBox(MazeTileMapNode.TileBox(x: 0, y: 1), side: .Up)
        maze.cutTileBox(MazeTileMapNode.TileBox(x: 1, y: 2), side: .Down)
        maze.cutTileBox(MazeTileMapNode.TileBox(x: 1, y: 1), side: .Down)
         
        //maze.cutTileBox(MazeTileMapNode.TileBox(x: 1, y: 1), side: .Left)
        maze.cutTileBox(MazeTileMapNode.TileBox(x: 0, y: 1), side: .Right)
    }

    func testVerticalCut() {
        let maze: MazeTileMapNode = MazeTileMapNode(columns: columns, rows: rows, boxSize: boxSize)
        reset(maze)
        
        maze.cutTileBox(MazeTileMapNode.TileBox(x: 1, y: 1), side: .Right)
        maze.cutTileBox(MazeTileMapNode.TileBox(x: 1, y: 0), side: .Right)
        maze.cutTileBox(MazeTileMapNode.TileBox(x: 1, y: 1), side: .Left)
        maze.cutTileBox(MazeTileMapNode.TileBox(x: 1, y: 0), side: .Left)

        //maze.cutTileBox(MazeTileMapNode.TileBox(x: 1, y: 0), side: .Up)
        maze.cutTileBox(MazeTileMapNode.TileBox(x: 1, y: 1), side: .Down)
    }
 
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
