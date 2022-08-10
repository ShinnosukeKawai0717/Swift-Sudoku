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
                sudoku.board[indexPath.section].columns[indexPath.row].value!.number = newValue
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func updateForHint(sudoku: Sudoku, newValue: Int, at indexPath: IndexPath) {
        do {
            try realm.write({
                sudoku.board[indexPath.section].columns[indexPath.row].value!.number = newValue
                sudoku.board[indexPath.section].columns[indexPath.row].value!.isHint = true
                sudoku.board[indexPath.section].columns[indexPath.row].value!.isPrefilled = true
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func updateNote(sudoku: Sudoku, newNote: String, at indexPath: IndexPath) {
        do {
            try realm.write({
                if sudoku.board[indexPath.section].columns[indexPath.row].value!.notes.contains(newNote) {
                    sudoku.board[indexPath.section].columns[indexPath.row].value!.notes.remove(newNote)
                }else {
                    sudoku.board[indexPath.section].columns[indexPath.row].value!.notes.insert(newNote)
                }
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
                        realm.delete(colum.value!)
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
