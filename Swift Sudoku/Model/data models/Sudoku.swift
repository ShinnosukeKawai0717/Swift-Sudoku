//
//  Favorite.swift
//  Sudoku
//
//  Created by Shinnosuke Kawai on 7/8/22.
//

import Foundation
import RealmSwift

class Value: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted(originProperty: "value") private var value: LinkingObjects<Column>
    @Persisted var number: Int = 0
    @Persisted var isHint: Bool = false
    @Persisted var isPrefilled: Bool = false
    @Persisted var notes: MutableSet<String>

    init(num: Int) {
        self.number = num
        self.isHint = false
        self.isPrefilled = num != 0 ? true : false
        self.notes = MutableSet()
    }
    
    init(column: Column) {
        self.number = column.value!.number
        self.isHint = column.value!.isHint
        self.isPrefilled = column.value!.isPrefilled
        self.notes = column.value!.notes
    }
    
    override init() {
        super.init()
    }
}


class Column: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted(originProperty: "columns") private var colum: LinkingObjects<Row>
    @Persisted var value: Value?
    
    init(value : Value) {
        self.value = value
    }
    
    override init() {
        super.init()
    }
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
    @Persisted var clock: Clock? = Clock()
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
                let valObj = Value(column: column)
                let columnObj = Column(value: valObj)
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
