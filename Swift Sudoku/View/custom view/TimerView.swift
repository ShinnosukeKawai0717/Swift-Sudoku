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
    private var model: Time
    private var shouldStop = false
    private var mistakeCount: Int = 0
    
    init(frame: CGRect, time: Time) {
        self.model = time
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
            if strongSelf.model.second == 60  {
                strongSelf.model.second = 0
                strongSelf.model.minute += 1
            }
            if strongSelf.model.minute == 60 {
                strongSelf.model.second = 0
                strongSelf.model.minute = 0
                strongSelf.model.hour += 1
            }
            strongSelf.timerLabel.text = strongSelf.model.timeForDisplay
            
            strongSelf.model.second += 1
        }
    }
    
    func getCurrentTime() -> String {
        return self.model.timeForDisplay
    }
    
    func stopTimer() {
        self.shouldStop = true
    }
    func restart() {
        self.shouldStop = false
        self.startTimer()
    }
    func resetTimer() {
        self.model.second = 0
        self.model.minute = 0
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
