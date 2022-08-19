//
//  MyView.swift
//  Swift Sudoku
//
//  Created by Shinnosuke Kawai on 8/17/22.
//

import Foundation
import UIKit

class ClockView: UIView {
    
    private let ImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        view.image = UIImage(systemName: "clock", withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemGray))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let timeLable: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.axis = .horizontal
        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(ImageView)
        stackView.addArrangedSubview(timeLable)
        addSubview(stackView)
    }
    
    public func configureClockLable(with clock: String) {
        DispatchQueue.main.async {
            self.timeLable.text = clock
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
