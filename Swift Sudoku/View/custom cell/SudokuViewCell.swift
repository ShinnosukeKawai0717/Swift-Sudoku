//
//  SudokuCollectionViewCell.swift
//  Sudoku
//
//  Created by Shinnosuke Kawai on 6/25/22.
//

import UIKit

class SudokuViewCell: UICollectionViewCell {
    static let identifier = "sudokuCollectionViewCell"
    
    private let cellLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        contentView.addSubview(cellLabel)
    }
    
    public func configureLabel(with number: String, textColor: UIColor, backGroundColor: UIColor) {
        DispatchQueue.main.async {
            self.cellLabel.backgroundColor = backGroundColor
            self.cellLabel.text = number
            self.cellLabel.textColor = textColor
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellLabel.backgroundColor = nil
        self.cellLabel.text = nil
        self.cellLabel.textColor = nil
        self.selectedBackgroundView = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            cellLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            cellLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            cellLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cellLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
        self.selectedBackgroundView = {
            let view = UIView()
            view.frame = bounds
            view.backgroundColor = .systemGray.withAlphaComponent(0.3)
            return view
        }()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override var isHighlighted: Bool {
        willSet {
        }
        didSet {
        }
    }
}
