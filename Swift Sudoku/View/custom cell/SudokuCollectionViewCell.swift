//
//  SudokuCollectionViewCell.swift
//  Sudoku
//
//  Created by Shinnosuke Kawai on 6/25/22.
//

import UIKit

class SudokuCollectionViewCell: UICollectionViewCell {
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
    }
    
    public func configure(with number: String) {
        DispatchQueue.main.async {
            self.cellLabel.text = number
        }
    }
    
    public func configureLabel(with number: String, textColor: UIColor) {
        DispatchQueue.main.async {
            self.cellLabel.text = number
            self.cellLabel.textColor = textColor
        }
    }
    
    public func configureLabel(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        DispatchQueue.main.async {
            self.cellLabel.addBorder(toSide: edge, withColor: color, andThickness: thickness)
        }
    }
    
    public func configure(backGroundColor: UIColor) {
        DispatchQueue.main.async {
            self.cellLabel.backgroundColor = .systemGray2
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contentView.backgroundColor = nil
        self.cellLabel.text = nil
        self.cellLabel.textColor = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(cellLabel)
        NSLayoutConstraint.activate([
            cellLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
