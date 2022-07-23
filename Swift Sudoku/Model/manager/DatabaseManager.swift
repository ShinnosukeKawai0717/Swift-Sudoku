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
                sudoku.board[indexPath.section].rowValues[indexPath.row].number = newValue
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func updateForHint(sudoku: Sudoku, newValue: Int, at indexPath: IndexPath) {
        do {
            try realm.write({
                sudoku.board[indexPath.section].rowValues[indexPath.row].number = newValue
                sudoku.board[indexPath.section].rowValues[indexPath.row].isHint = true
                sudoku.board[indexPath.section].rowValues[indexPath.row].isZero = false
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func delete(favorite: Sudoku) {
        do {
            try realm.write({
                for colum in favorite.board {
                    for row in colum.rowValues {
                        realm.delete(row)
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
