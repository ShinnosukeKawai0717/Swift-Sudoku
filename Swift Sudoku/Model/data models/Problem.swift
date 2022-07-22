//
//  Sudoku.swift
//  Sudoku
//
//  Created by Shinnosuke Kawai on 7/17/22.
//

import Foundation

struct APIResponse: Codable {
    let response: Problem?
}

struct Problem: Codable {
    let unsolvedSudoku: [[Int]]?
    
    enum CodingKeys: String, CodingKey {
        case unsolvedSudoku = "unsolved-sudoku"
    }
}
