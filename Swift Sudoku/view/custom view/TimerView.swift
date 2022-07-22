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
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            if strongSelf.second == 60  {
                strongSelf.second = 0
                strongSelf.minutes += 1
            }
            let second_str = strongSelf.second < 10 ? "0\(strongSelf.second)" : "\(strongSelf.second)"
            let minu_str = strongSelf.minutes < 10 ? "0\(strongSelf.minutes)" : "\(strongSelf.minutes)"
            
            DispatchQueue.main.async {
                strongSelf.timerLabel.text = "\(minu_str) : \(second_str)"
            }
            strongSelf.second += 1
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
