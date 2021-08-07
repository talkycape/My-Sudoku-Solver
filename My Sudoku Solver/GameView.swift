//
//  ContentView.swift
//  My Sudoku Solver
//
//  Created by Ya-Chieh Lai on 8/3/21.
//  With thanks to: https://github.com/pgalhardo/Sudoku
//

import SwiftUI

struct GameView: View {

    @StateObject private var grid: Grid = Grid()
    @State var solved: Int = 0
    @State var executionTime: Double = 0
    @State var startIter: Bool = false
    @State var prev: Int = 0
    @State var pos: Int = 0
    @State var nextprev: Int = 0
    @State var nextpos: Int = 0
    @State var doneIter: Bool = false
 
    private let frameSize: CGFloat = min(Screen.cellWidth, 45) * 9
        
    @ViewBuilder
    var body: some View {
        VStack(spacing: 0) {
            Text("Sudoku Solver!")
                .font(.title)
            ZStack {
                self.renderStructure(width: frameSize / 9)
                self.renderOverlayLines(width: frameSize / 9)
            }
            .frame(width: frameSize,
                   height: frameSize,
                   alignment: .center)
            VStack {
                HStack {
                    Button(action: {
                        self.solved = 0
                        self.executionTime = 0
                        self.grid.reset()
                        self.grid.generate()
                    }, label: {
                        Text("New Puzzle")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    })
                    Button(action: {
                        let startTime = CFAbsoluteTimeGetCurrent()
                        solved = self.grid.solve()
                        let endTime = CFAbsoluteTimeGetCurrent()
                        executionTime = endTime - startTime
                    }, label: {
                        Text("Solve Puzzle")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    })
                    Button(action: {
                        self.solved = 0
                        self.grid.clear()
                    }, label: {
                        Text("Clear Puzzle")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    })
                }
                Text("Stats: Solved in \(executionTime) seconds")
                Button(action: {
                    self.grid.useBasicTechniques.toggle()
                }, label: {
                    if self.grid.useBasicTechniques {
                        Text("Disable Basic Techniques")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)

                    } else {
                        Text("Enable Basic Techniques")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                })
            }
        }
    }
    
    // draw the main sudoku grid
    private func renderStructure(width: CGFloat) -> some View {
        VStack(spacing: -1) {
            ForEach(0 ..< 9) { row in
                HStack(spacing: -1) {
                    ForEach(0 ..< 9) { col in
                        self.grid.render(
                            row: row,
                            col: col,
                            fontSize: self.fontSize()
                        )
                        .frame(
                            width: width,
                            height: width
                        )
                        .border(Color.black, width: 1)
                        .padding(.all, 0)
                        .background(Color.white)
                    }
                }
            }
        }
    }
    
    // overlays those thick lines
    private func renderOverlayLines(width: CGFloat) -> some View {
        GeometryReader { geometry in
            Path { path in
                let factor: CGFloat = width * 3
                let lines: [CGFloat] = [1, 2]
                
                for i: CGFloat in lines {
                    let vpos: CGFloat = i * factor
                    path.move(to: CGPoint(x: vpos, y: 4))
                    path.addLine(to: CGPoint(x: vpos, y: geometry.size.height - 4))
                }
                
                for i: CGFloat in lines {
                    let hpos: CGFloat = i * factor
                    path.move(to: CGPoint(x: 4, y: hpos))
                    path.addLine(to: CGPoint(x: geometry.size.width - 4, y: hpos))
                }
            }
            .stroke(lineWidth: Screen.lineThickness)
            .foregroundColor(.black)
        }
    }
    
    func fontSize() -> CGFloat {
        let size: Float = 28.0
        return CGFloat(size as Float)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
