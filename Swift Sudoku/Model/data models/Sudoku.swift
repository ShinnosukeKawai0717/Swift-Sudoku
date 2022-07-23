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
    @Persisted(originProperty: "rowValues") private var colum: LinkingObjects<Column>
    
    @Persisted private var value: Int = 0
    public var isZero: Bool = false
    public var textColor: UIColor = .systemCyan
    
    var number: Int {
        get {
            return value
        }
        set {
            value = newValue
        }
    }
    
    override class func ignoredProperties() -> [String] {
        return ["number", "isZero", "textColor"]
    }
}

class Column: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted(originProperty: "unsolvedSudoku") private var sudoku: LinkingObjects<Sudoku>
    
    @Persisted var rowValues = List<Value>()
}

class Sudoku: Object, ObjectKeyIdentifiable, NSCopying {
    
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var name: String = ""
    @Persisted var dateAdded: Date = Date()
    @Persisted private var difficulty = ""
    @Persisted var unsolvedSudoku = List<Column>()
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
        for colum in unsolvedSudoku {
            let colums = Column()
            for row in colum.rowValues {
                let value = Value()
                value.number = row.number
                value.isZero = row.isZero
                colums.rowValues.append(value)
            }
            copy.unsolvedSudoku.append(colums)
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
