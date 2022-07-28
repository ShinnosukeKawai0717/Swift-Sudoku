//
//  DatabaseManager.swift
//  Sudoku
//
//  Created by Shinnosuke Kawai on 7/8/22.
//

import Foundation
import RealmSwift
import ProgressHUD

class DatabaseManager {
    private let realm = try! Realm()
    
    public func save(newFavorite: Sudoku) {
        do {
            try realm.write {
                
                realm.add(newFavorite)
                ProgressHUD.colorAnimation = .systemPink
                ProgressHUD.show(icon: .heart)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func update(sudoku: Sudoku, newValue: Int, at indexPath: IndexPath) {
        do {
            try realm.write({
                sudoku.board[indexPath.row].columns[indexPath.section].value = newValue
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func updateForHint(sudoku: Sudoku, newValue: Int, at indexPath: IndexPath) {
        do {
            try realm.write({
                sudoku.board[indexPath.row].columns[indexPath.section].value = newValue
                sudoku.board[indexPath.row].columns[indexPath.section].isHint = true
                sudoku.board[indexPath.row].columns[indexPath.section].isZero = false
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func updateNote(sudoku: Sudoku, newNote: String, at indexPath: IndexPath) {
        do {
            try realm.write({
                sudoku.board[indexPath.row].columns[indexPath.section].notes
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func delete(favorite: Sudoku) {
        do {
            try realm.write({
                for row in favorite.board {
                    for colum in row.columns {
                        realm.delete(colum)
                    }
                }
                realm.delete(favorite.board)
                realm.delete(favorite)
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func deleteAll() {
        do {
            try realm.write({
                realm.deleteAll()
            })
            printRealmURL()
        }catch {
            print(error.localizedDescription)
        }
    }
    
    public func retrive() -> Results<Sudoku> {
        
        let favorites = realm.objects(Sudoku.self)
        return favorites
    }
    
    public func printRealmURL() {
        print("File Path: \(String(describing: realm.configuration.fileURL?.absoluteString))")
    }
}
