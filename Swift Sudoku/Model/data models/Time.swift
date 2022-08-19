//
//  Time.swift
//  Swift Sudoku
//
//  Created by Shinnosuke Kawai on 8/16/22.
//

import Foundation

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
