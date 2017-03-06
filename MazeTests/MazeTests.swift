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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHorizontalCut() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let maze = MazeTileMapNode(columns: 3, rows: 3, boxSize: 3, groupName: "Sand")
 
        for c in 0..<3 {
            for r in 0..<3 {
                maze.drawTileBox(column: c, row: r)
            }
        }
        maze.cutTileBox(side: .Up, column: 0, row: 0)
        maze.cutTileBox(side: .Up, column: 0, row: 1)
        maze.cutTileBox(side: .Down, column: 1, row: 2)
        maze.cutTileBox(side: .Down, column: 1, row: 1)
         
        //maze.cutTileBox(side: .Left, column: 1, row: 1)
        maze.cutTileBox(side: .Right, column: 0, row: 1)
    }

    func testVerticalCut() {
        let maze = MazeTileMapNode(columns: 3, rows: 3, boxSize: 3, groupName: "Sand")
        
        for c in 0..<3 {
            for r in 0..<3 {
                maze.drawTileBox(column: c, row: r)
            }
        }
        
        maze.cutTileBox(side: .Right, column: 1, row: 1)
        maze.cutTileBox(side: .Right, column: 1, row: 0)
        maze.cutTileBox(side: .Left, column: 1, row: 1)
        maze.cutTileBox(side: .Left, column: 1, row: 0)

        //maze.cutTileBox(side: .Up, column: 1, row: 0)
        maze.cutTileBox(side: .Down, column: 1, row: 1)
    }
 
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
