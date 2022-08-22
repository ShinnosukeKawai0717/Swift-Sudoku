//
//  Time.swift
//  Swift Sudoku
//
//  Created by Shinnosuke Kawai on 8/16/22.
//

import Foundation
import RealmSwift
import CoreVideo

protocol TimeProtocol {
    var hour_str: String { get }
    var second_str: String { get }
    var minutes_str: String { get }
}

struct Time {
    var hour: Int
    var second: Int
    var minute: Int
    
    init() {
        self.second = 0
        self.minute = 0
        self.hour = 0
    }
    var timeForDisplay: String {
        get {
            if hour == 0 {
                return minutes_str + " : " + second_str
            }
            return hour_str + " : " + minutes_str + " : " + second_str
        }
    }
    
    private var hour_str: String {
        get {
            return hour<10 ? "0\(hour)" : "\(hour)"
        }
    }
    
    private var second_str: String {
        get {
            return second<10 ? "0\(second)" : "\(second)"
        }
    }
    
    private var minutes_str: String {
        get {
            return minute<10 ? "0\(minute)" : "\(minute)"
        }
    }
}

class Clock: Object, ObjectKeyIdentifiable, TimeProtocol {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted(originProperty: "clock") private var sudoku: LinkingObjects<Sudoku>
    
    @Persisted var timeTaken: String = "00:00"
    var hour_str: String {
        get {
            return hour<10 ? "0\(hour)" : "\(hour)"
        }
    }
    
    var second_str: String {
        get {
            return seconds<10 ? "0\(seconds)" : "\(seconds)"
        }
    }
    
    var minutes_str: String {
        get {
            return minutes<10 ? "0\(minutes)" : "\(minutes)"
        }
    }
    var hour: Int {
        get {
            if timeTaken.count > 6 {
                if timeTaken[0] == "0" {
                    return Int("\(timeTaken[1])")!
                }
                let str = "\(timeTaken[0])\(timeTaken[1])"
                return Int(str)!
            }
            return 0
        }
    }
    var minutes: Int {
        get {
            if timeTaken[3] == "0" {
                
            }
            return 0
        }
    }
    var seconds: Int {
        get {
            return 0
        }
    }
}
