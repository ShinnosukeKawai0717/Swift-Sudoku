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
                strongSelf.generateSudokuObject(unsolvedProblem: unsolvedProblem, diff: diff)
            } catch {
                completion(.failure(error))
            }
        })

        dataTask.resume()
    }
    
    fileprivate func generateSudokuObject(unsolvedProblem: [[Int]], diff: String) {
        let sudoku = Sudoku()
        sudoku.diff = diffDict[diff] ?? .easy
        for rows in unsolvedProblem {
            let rowObj = Row()
            for colum in rows {
                let colObj = Column()
                colObj.value = colum
                colObj.isZero = colum == 0 ? true : false
                colObj.isHint = false
                rowObj.columns.append(colObj)
            }
            sudoku.board.append(rowObj)
        }
        guard let completion = completion else {
            return
        }
        completion(.success(sudoku))
    }
    
    public func solve(sudoku: Sudoku) -> Sudoku? {
        if let emptyIndexPath = getEmptyIndex(sudoku: sudoku) {
            for possibleNum in 1...9 {
                if isValiedPlacement(board: sudoku, number: possibleNum, row: emptyIndexPath.row, colum: emptyIndexPath.section) {
                    sudoku.board[emptyIndexPath.row].columns[emptyIndexPath.section].value = possibleNum
                    if self.solve(sudoku: sudoku) != nil {
                        return sudoku
                    }
                }
                sudoku.board[emptyIndexPath.row].columns[emptyIndexPath.section].value = 0
            }
            return nil
        }else {
            return sudoku
        }
    }
    
    private func getEmptyIndex(sudoku: Sudoku) -> IndexPath? {
        
        for row in 0..<9 {
            for colum in 0..<9 {
                if sudoku.board[row].columns[colum].value == 0 {
                    return IndexPath(row: row, section: colum)
                }
            }
        }
        
        return nil
    }
    
    private func isNumberInRow(board: Sudoku, number: Int, row: Int) -> Bool {
        for i in 0..<9 {
            if board.board[row].columns[i].value == number {
                return true
            }
        }
        return false
    }
    private func isNumberInColum(board: Sudoku, number: Int, colum: Int) -> Bool {
        for i in 0..<9 {
            if board.board[i].columns[colum].value == number {
                return true
            }
        }
        return false
    }
    
    private func isNumberInSubBox(board: Sudoku, number: Int, colum: Int, row: Int) -> Bool {
        let localRow: Int = row - row % 3
        let localColum: Int = colum - colum % 3
        for i in localRow..<localRow + 3 {
            for j in localColum..<localColum + 3 {
                if board.board[i].columns[j].value == number {
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
