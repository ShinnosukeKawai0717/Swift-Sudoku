//
//  NumCell.swift
//  Swift Sudoku
//
//  Created by Shinnosuke Kawai on 7/27/22.
//

import UIKit

class NumCell: UICollectionViewCell {
    
    static let identifier = "NumCell"
    
    private let numLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .systemRed
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(numLabel)
    }
    
    func configure(text: String) {
        DispatchQueue.main.async {
            self.numLabel.text = text
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.numLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            numLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            numLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            numLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            numLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
