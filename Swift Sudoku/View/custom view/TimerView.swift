//
//  TimerView.swift
//  Sudoku
//
//  Created by Shinnosuke Kawai on 7/16/22.
//

import Foundation
import UIKit

class TimerView: UIView {
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var second: Int = 0
    private var minutes: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(timerLabel)
    }
    func configure(text: String) {
        DispatchQueue.main.async {
            self.timerLabel.text = text
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
