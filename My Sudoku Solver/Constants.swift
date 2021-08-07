//
//  Constants.swift
//  My Sudoku Solver
//
//  Created by Ya-Chieh Lai on 8/3/21.
//  With thanks to: https://github.com/pgalhardo/Sudoku
//

import Foundation
import SwiftUI

let UNDEFINED: Int = 0

enum Screen {
    static let size: CGRect = UIScreen.main.bounds
    static let width: CGFloat = UIScreen.main.bounds.width
    static let height: CGFloat = UIScreen.main.bounds.height
    static let cellWidth: CGFloat = UIScreen.main.bounds.size.width * 0.95 / 9
    static let lineThickness: CGFloat = 2
}

enum InputType {
    static let system: Int = 0
    static let user:   Int = 1
    static let error:  Int = 2
}

enum Colors {
    static let DeepBlue:   Color = Color(red: 45 / 255,
                                         green: 75 / 255,
                                         blue: 142 / 255)
    static let ActiveBlue: Color = Color.blue
    static let LightBlue:  Color = Color(red: 45 / 255,
                                         green: 75 / 255,
                                         blue: 75 / 255)

    static let MatteBlack: Color = Color(red: 27 / 255,
                                         green: 27 / 255,
                                         blue: 27 / 255)
    static let Golden:     Color = Color.yellow
}

enum Puzzles {
    static let easy: [String] = [
        "020590030070000100000000070610000007500000090000000302000010000860300050103400900",
        "010006008062000705400000200000400000380000001000700536500064090000000000270030050",
        "008070200900501008000800700050000040000687103000000800029005000000000030010900006",
        "028000090000000004309800000050080040900072600706000010000040000275000000000030187",
        "000004090020890000500002008000300001200009040050010030080000006900000500000460070"
    ]
}
