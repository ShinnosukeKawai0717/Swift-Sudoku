//
//  Cell.swift
//  Sudoku
//
//  Created by Shinnosuke Kawai on 7/12/22.
//

import Foundation
import UIKit

enum ToastType {
    case info
    case success
    case failed
    case error
}

struct Toast {
    let type: ToastType
    let message: String
    let image: UIImage?
}
