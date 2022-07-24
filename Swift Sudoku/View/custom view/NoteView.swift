//
//  NoteView.swift
//  Swift Sudoku
//
//  Created by Shinnosuke Kawai on 7/24/22.
//

import Foundation
import UIKit

class NoteView: UIView {
    
    var notes: [String]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
