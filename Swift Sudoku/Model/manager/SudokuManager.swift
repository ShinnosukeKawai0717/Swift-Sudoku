//
//  SudokuManager.swift
//  Sudoku
//
//  Created by Shinnosuke Kawai on 6/28/22.
//

import Foundation
import RealmSwift

class SudokuManager {
    static let shared = SudokuManager()
    private var completion: ((Result<Sudoku, Error>) -> Void)?
    private let headers = [
        "X-RapidAPI-Key": "e6582f32a9msh5d1749fcb311f4dp155dd1jsn0e2bfdf0381a",
        "X-RapidAPI-Host": "sudoku-board.p.rapidapi.com"
    ]
    
    private let diffDict = ["1":Difficulty.easy, "2": Difficulty.medium, "3": Difficulty.hard]
    
    public func generate(diff: String, completion: @escaping (Result<Sudoku, Error>) -> Void) {
        self.completion = completion
        guard let url = URL(string: "https://sudoku-board.p.rapidapi.com/new-board?diff=\(diff)&stype=list&solu=false") else {
            return
        }
        var urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = self.headers

        let dataTask = URLSession.shared.dataTask(with: urlRequest, completionHandler: { [weak self] (data, _, error) -> Void in
            guard let data = data, error == nil, let strongSelf = self else {
                return
            }
            do {
                let result = try JSONDecoder().decode(APIResponse.self, from: data)
                
                guard let sudoku = result.response else {
                    print("Sudoku object is null")
                    return
                }
                guard let unsolvedProblem = sudoku.unsolvedSudoku else {
                    print("UnsolvedProblem is null")
                    return
                }
                strongSelf.generateTwoDArrOfNumber(unsolvedProblem: unsolvedProblem, diff: diff)
            } catch {
                completion(.failure(error))
            }
        })

        dataTask.resume()
    }
    
    fileprivate func generateTwoDArrOfNumber(unsolvedProblem: [[Int]], diff: String) {
        let sudoku = Sudoku()
        sudoku.diff = diffDict[diff] ?? .easy
        for colum in unsolvedProblem {
            let columObj = Column()
            for row in colum {
                let value = Value()
                value.number = row
                value.isZero = row == 0 ? true : false
                value.isHint = false
                columObj.rowValues.append(value)
            }
            sudoku.unsolvedSudoku.append(columObj)
        }
        guard let completion = completion else {
            return
        }
        completion(.success(sudoku))
    }
    
    public func solve(sudoku: Sudoku) -> Sudoku? {
        for colum in 0..<9 {
            for row in 0..<9 {
                if sudoku.unsolvedSudoku[colum].rowValues[row].number == 0 {
                    for possibleNumber in 1...9 {
                        if isValiedPlacement(board: sudoku, number: possibleNumber, row: row, colum: colum) {
                            sudoku.unsolvedSudoku[colum].rowValues[row].number = possibleNumber
                            let result = solve(sudoku: sudoku)
                            if result != nil {
                                return result
                            }
                            sudoku.unsolvedSudoku[colum].rowValues[row].number = 0
                        }
                    }
                    return nil
                }
            }
        }
        return sudoku
    }
    
    private func isNumberInRow(board: Sudoku, number: Int, row: Int) -> Bool {
        for i in 0..<9 {
            if board.unsolvedSudoku[i].rowValues[row].number == number {
                return true
            }
        }
        return false
    }
    private func isNumberInColum(board: Sudoku, number: Int, colum: Int) -> Bool {
        for i in 0..<9 {
            if board.unsolvedSudoku[colum].rowValues[i].number == number {
                return true
            }
        }
        return false
    }
    
    private func isNumberInSubBox(board: Sudoku, number: Int, colum: Int, row: Int) -> Bool {
        let localRow: Int = row - row % 3
        let localColum: Int = colum - colum % 3
        for i in localColum..<localColum + 3 {
            for j in localRow..<localRow + 3 {
                if board.unsolvedSudoku[i].rowValues[j].number == number {
                    return true
                }
            }
        }
        return false
    }
    
    private func isValiedPlacement(board: Sudoku, number: Int, row: Int, colum: Int) -> Bool{
        return !isNumberInRow(board: board, number: number, row: row) &&
                !isNumberInColum(board: board, number: number, colum: colum) &&
                !isNumberInSubBox(board: board, number: number, colum: colum, row: row)
    }
}
