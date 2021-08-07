//
//  GameViewModel.swift
//  My Sudoku Solver
//
//  Created by Ya-Chieh Lai on 8/3/21.
//  With thanks to: https://github.com/pgalhardo/Sudoku
//

import Foundation
import SwiftUI

final class Grid: ObservableObject {
    
    @Published private var grid: [[Int]] = [[Int]]()
    @Published private var solution: [[Int]] = [[Int]]()
    
    @Published private var inputType: [[Int]] = [[Int]]()
    @Published var useBasicTechniques: Bool = true
    
    private var solutions: Int = 0
    
    init() {
        self.grid = Array(
            repeating:Array(repeating: UNDEFINED, count: 9),
            count: 9
        )
        self.inputType = Array(
            repeating: Array(repeating: InputType.user, count: 9),
            count: 9
        )
        self.generate()
    }
 
    /*==========================================================================
        Core functions
    ==========================================================================*/

    // clear everything
    func reset() -> Void {
        
        self.grid = Array(
            repeating: Array(repeating: UNDEFINED, count: 9),
            count: 9
        )
        self.inputType = Array(
            repeating: Array(repeating: InputType.user, count: 9),
            count: 9
        )
    }

    // clear solution but keep original puzzle
    func clear() -> Void {
        for row: Int in (0 ..< 9) {
            for col: Int in (0 ..< 9) {
                let type: Int = inputType[row][col]
                if type != InputType.system {
                    grid[row][col] = UNDEFINED
                }
            }
        }
    }

    func render(row: Int, col: Int, fontSize: CGFloat) -> Text {
        
        let value: Int = grid[row][col]
        let type: Int = inputType[row][col]
        
        if value == UNDEFINED { return Text(" ") }
        
        if type == InputType.system {
            return Text("\(value)")
                .font(.custom("CaviarDreams-Bold",
                              size: fontSize))
                .foregroundColor(Color(.label))
        } else if type == InputType.user {
            return Text("\(value)")
                .font(.custom("CaviarDreams-Bold",
                              size: fontSize))
                .foregroundColor(Colors.Golden)
        }
        return Text("\(value)")
            .font(.custom("CaviarDreams-Bold",
                          size: fontSize))
            .foregroundColor(Color(.systemPink))
    }
    
    func loadFromSeed() -> Void {
        let randPuzzle: Int = Int.random(in: 0 ..< Puzzles.easy.count)
        
        var str: String = Puzzles.easy[randPuzzle]
        var count: Int = 0
        
        while !str.isEmpty {
            let row: Int = count / 9
            let col: Int = count % 9
            let char: Character = str.removeFirst()
            
            if "0" <= char && char <= "9" {
                let char2String: String = String(char)
                let value: Int = Int(char2String) ?? 0
                
                self.grid[row][col] = value
                if value != UNDEFINED {
                    self.inputType[row][col] = InputType.system
                } else {
                    self.inputType[row][col] = InputType.user
                }
                
                count += 1
            }
        }
    }
  
    func full() -> Bool {
        for row: Int in (0 ..< 9) {
            for col: Int in (0 ..< 9) {
                if self.grid[row][col] == UNDEFINED {
                    return false
                }
            }
        }
        return true
    }
    
    func completion() -> Int {
        var filled: Int = 0
        
        for row: Int in (0 ..< 9) {
            for col: Int in (0 ..< 9) {
                if grid[row][col] != UNDEFINED {
                    filled += 1
                }
            }
        }
        return filled * 100 / 81
    }

    /*==========================================================================
        Single cell actions
    ==========================================================================*/
    
    func valueAt(row: Int, col: Int) -> Int {
        return grid[row][col]
    }
    
    /*==========================================================================
        Generator
    ==========================================================================*/

    func generate() -> Void {
        loadFromSeed()
    }
    
    /*==========================================================================
        Groups of cells
    ==========================================================================*/
    
    func getSquare(row: Int, col: Int) -> [[Int]] {
        // this points to upper left corner
        let row: Int = (row / 3) * 3
        let col: Int = (col / 3) * 3
        var square: [[Int]] = [[Int]]()
        
        for i: Int in (row ..< row + 3) {
            square.append([grid[i][col],
                           grid[i][col + 1],
                           grid[i][col + 2]])
        }
        return square
    }
    
    func numberInRow(number: Int, row: Int) -> Bool {
        return grid[row].filter { $0 == number }.count > 0
    }
    
    func numberInCol(number: Int, col: Int) -> Bool {
        return grid.filter { $0[col] == number }.count > 0
    }
    
    func numberInSquare(number: Int, row: Int, col: Int) -> Bool {
        let square: [[Int]] = getSquare(row: row, col: col)
        
        return (square[0].contains(number)
            || square[1].contains(number)
            || square[2].contains(number))
    }
    
    func possible(number: Int, row: Int, col: Int) -> Bool {
        return !numberInRow(number: number, row: row)
            && !numberInCol(number: number, col: col)
            && !numberInSquare(number: number, row: row, col: col)
    }
    

    /*==========================================================================
        Solver
    ==========================================================================*/

    func solve() -> Int {
        solutions = 0
        
        if useBasicTechniques {
            // first fill in the obvious solutions if they exist
            // (naked singles or hidden singles)
            basicTechniques()
        }
        
        if full() {
            solutions = 1
        }
        // now do the brute force algorithm
        else {
            self.solution = Array(
                repeating: Array(repeating: UNDEFINED, count: 9),
                count: 9
            )
            backtrack(prev: -1, pos: nextEmptyPos(ref: -1))
            self.grid = self.solution
        }
        
        return solutions
    }
 
    
    func basicTechniques() -> Void {
        
        // A naked single is a cell that has only one possible option
        // (e.g. can't be anything else because other numbers are already
        //  used in related row, column, and square)
        func nakedSingles(possibles: [[[Int]]]) -> Int {
            var solved: Int = 0
            
            for row in (0 ..< 9) {
                for col in (0 ..< 9) {
                    // calculate how many possible there are at a row/column combination
                    // and see if it is "naked" (only one solution)
                    if possibles[row][col].count == 1 {
                        solved += 1
                        grid[row][col] = possibles[row][col][0]
                    }
                }
            }
            return solved
        }
        
        // a hidden single is a cell which contains an option
        // not found anywhere else in its row, column, or square
        // (e.g. a cell that must be 7 because it is the only 7 in its column)
        func hiddenSingles(possibles: [[[Int]]]) -> Int {
            
            func uniqueRow(row: Int, value: Int, possibles: [[Int]]) -> Bool {
                var count: Int = 0
                var index: Int = 0
                
                for col in (0 ..< 9) {
                    for inner in (0 ..< possibles[col].count) {
                        if possibles[col][inner] == value {
                            count += 1
                            index = col
                        }
                    }
                }
                
                if count == 1 {
                    grid[row][index] = value
                }
                return count == 1
            }
            
            func uniqueCol(col: Int, value: Int, possibles: [[Int]]) -> Bool {
                var count: Int = 0
                var index: Int = 0
                
                for row in (0 ..< 9) {
                    for inner in (0 ..< possibles[row].count) {
                        if possibles[row][inner] == value {
                            count += 1
                            index = row
                        }
                    }
                }
                
                if count == 1 {
                    grid[index][col] = value
                }
                return count == 1
            }
            
            func uniqueSquare(row: Int, col: Int, value: Int,
                              possibles: [[[Int]]]) -> Bool {
                
                var square: [[Int]] = [[Int]]()
                for i in (row ..< row + 3) {
                    for j in (col ..< col + 3) {
                        square.append(possibles[i][j])
                    }
                }
                
                var count: Int = 0
                var index: Int = 0
                for outter in (0 ..< 9) {
                    for inner in (0 ..< square[outter].count) {
                        if square[outter][inner] == value {
                            count += 1
                            index = outter
                        }
                    }
                }
                
                if count == 1 {
                    let rowOffset: Int = index / 3
                    let colOffset: Int = index % 3
                    grid[row + rowOffset][col + colOffset] = value
                }
                return count == 1
            }
            
            var found: Int = 0
            
            // detect hidden singles in rows
            for row: Int in (0 ..< 9) {
                for value: Int in (1 ... 9) {
                    if uniqueRow(row: row,
                                 value: value,
                                 possibles: possibles[row]
                        ) {
                        found += 1
                    }
                }
            }
            
            // detect hidden singles in columns
            for col in (0 ..< 9) {
                for value in (1 ... 9) {
                    if uniqueCol(col: col,
                                 value: value,
                                 possibles: possibles.map { $0[col] }
                        ) {
                        found += 1
                    }
                }
            }
            
            // detect hidden singles in square
            let delim: [Int] = [0, 3, 6]
            for row in delim {
                for col in delim {
                    for value in (1 ... 9) {
                        if uniqueSquare(row: row,
                                        col: col,
                                        value: value,
                                        possibles: possibles
                            ) {
                            found += 1
                        }
                    }
                }
            }
            return found
        }
        
        while true {
            let possibles: [[[Int]]] = computeGridPossibles()
            
            if nakedSingles(possibles: possibles) > 0 { continue }
            else if hiddenSingles(possibles: possibles) > 0 { continue }
            
            break
        }
    }
    
    @discardableResult func backtrack(prev: Int, pos: Int) -> Bool {
            let row: Int = pos / 9
            let col: Int = pos % 9
            
            var possibles: [Int] = getPossibles(row: row, col: col)
            
            while possibles.count > 0 {
                
                // grab a possible value and store as "first"
                let first: Int = possibles.removeFirst()
                grid[row][col] = first
                
                let nextpos: Int = nextEmptyPos(ref: pos)
                if nextpos == -1 {

                    solution = grid

                    // If we want to check if other solutions exist,
                    // we can do the following to repeat:
//                    solutions += 1
//                    if solutions > 1 {
//                        solution = Array(repeating: Array(repeating: UNDEFINED,
//                                                          count: 9),
//                                         count: 9)
//                        return false
//                    }
//                    else {
//                        solution = grid
//                    }
                }
                else {
                    backtrack(prev: pos, pos: nextpos)
                    if solutions > 1 {
                        return false
                    }
                }
                
                // If we got here, everything after us failed.
                // We need to try another possible number.
            }
            
            grid[row][col] = UNDEFINED
            return false
        }
    
    func nextEmptyPos(ref: Int) -> Int {
        var nextpos: Int = ref + 1
        
        // iterate over every position until you encounter an empty one
        while true {
            let nextrow: Int = nextpos / 9
            let nextcol: Int = nextpos % 9
            if nextpos > 80 {
                // Board is filled
                return -1
            }
            else if grid[nextrow][nextcol] == UNDEFINED {
                return nextpos
            }
            nextpos += 1
        }
    }
    
    func getPossibles(row: Int, col: Int) -> [Int] {
        var possibles: [Int] = []
        
        for i in (1 ... 9) {
            if possible(token: i, row: row, col: col) {
                possibles.append(i)
            }
        }
        return possibles
    }
    
    func computeGridPossibles() -> [[[Int]]] {
        var possibles: [[[Int]]] = Array(repeating: Array(repeating: [],
                                                          count: 9),
                                         count: 9)
        
        for row in (0 ..< 9) {
            for col in (0 ..< 9) {
                if grid[row][col] == UNDEFINED {
                    possibles[row][col] = getPossibles(row: row, col: col)
                }
            }
        }
        return possibles
    }

    func possible(token: Int, row: Int, col: Int) -> Bool {
        return !tokenInRow(token: token, row: row)
            && !tokenInCol(token: token, col: col)
            && !tokenInSquare(token: token, row: row, col: col)
    }
    
    func tokenInRow(token: Int, row: Int) -> Bool {
        return grid[row].filter { $0 == token }.count > 0
    }
    
    
    func tokenInCol(token: Int, col: Int) -> Bool {
        return grid.filter { $0[col] == token }.count > 0
    }
    
    
    func tokenInSquare(token: Int, row: Int, col: Int) -> Bool {
        let square: [[Int]] = getSquare(row: row, col: col)
        
        return square[0].contains(token)
            || square[1].contains(token)
            || square[2].contains(token)
    }

}

