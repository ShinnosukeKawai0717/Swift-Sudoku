//
//  Favorite.swift
//  Sudoku
//
//  Created by Shinnosuke Kawai on 7/8/22.
//

import Foundation
import RealmSwift


class Column: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted(originProperty: "columns") private var colum: LinkingObjects<Row>
    @Persisted var value: Int = 0
    @Persisted var isHint: Bool = false
    @Persisted var isZero: Bool = false
    @Persisted var notes = List<String>()
}

class Row: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted(originProperty: "board") private var sudoku: LinkingObjects<Sudoku>
    
    @Persisted var columns = List<Column>()
}

class Sudoku: Object, ObjectKeyIdentifiable, NSCopying {
    
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var name: String = ""
    @Persisted var dateAdded: Date = Date()
    @Persisted private var difficulty = ""
    @Persisted var board = List<Row>()
    var diff: Difficulty {
        get {
            return Difficulty(rawValue: difficulty.lowercased()) ?? .easy
        }
        set {
            difficulty = newValue.rawValue.capitalized
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Sudoku()
        copy.name = name
        copy.dateAdded = dateAdded
        copy.diff = diff
        for rows in board {
            let rowCopy = Row()
            for column in rows.columns {
                let columnObj = Column()
                columnObj.value = column.value
                columnObj.isZero = column.isZero
                columnObj.isHint = column.isHint
                columnObj.notes = column.notes
                rowCopy.columns.append(columnObj)
            }
            copy.board.append(rowCopy)
        }
        return copy
    }
}

enum Difficulty: String {
    case easy
    case medium
    case hard
    
    func getNumber() -> String {
        switch self {
        case .easy:
            return "1"
        case .medium:
            return "2"
        case .hard:
            return "3"
        }
    }
}
