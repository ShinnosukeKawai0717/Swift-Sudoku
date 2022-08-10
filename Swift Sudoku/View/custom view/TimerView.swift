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
        label.text = "00 : 00"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var mistakeLabel: UILabel = {
        let label = UILabel()
        label.text = "Mistakes: \(mistakeCount)"
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var shouldStop = false
    private var second: Int = 0
    private var minutes: Int = 0
    private var mistakeCount: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(timerLabel)
        addSubview(mistakeLabel)
    }
    func incrementMistake() {
        DispatchQueue.main.async {
            self.mistakeCount += 1
            self.mistakeLabel.text = "Mistakes: \(self.mistakeCount)"
        }
    }
    func resetMistakeCounter() {
        DispatchQueue.main.async {
            self.mistakeCount = 0
            self.mistakeLabel.text = "Mistakes: \(self.mistakeCount)"
        }
    }
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            if strongSelf.shouldStop {
                 timer.invalidate()
            }
            if strongSelf.second == 60  {
                strongSelf.second = 0
                strongSelf.minutes += 1
            }
            let second_str = strongSelf.second < 10 ? "0\(strongSelf.second)" : "\(strongSelf.second)"
            let minu_str = strongSelf.minutes < 10 ? "0\(strongSelf.minutes)" : "\(strongSelf.minutes)"
            
            strongSelf.timerLabel.text = "\(minu_str) : \(second_str)"
            
            strongSelf.second += 1
        }
    }
    
    func stopTimer() {
        self.shouldStop = true
    }
    func restart() {
        self.shouldStop = false
        self.startTimer()
    }
    func resetTimer() {
        self.second = 0
        self.minutes = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            mistakeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            mistakeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            timerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
