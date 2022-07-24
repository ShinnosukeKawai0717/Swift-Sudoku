//
//  keyBoardCollectionViewCell.swift
//  Sudoku
//
//  Created by Shinnosuke Kawai on 6/26/22.
//

import UIKit

class KeyBoardCell: UICollectionViewCell {
    static let identifier = "keyBoardCell"
    
    private let numLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        layer.cornerRadius = layer.frame.size.height / 2
        contentView.addSubview(numLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            numLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            numLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            numLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            numLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with number: String) {
        DispatchQueue.main.async {
            self.numLabel.text = number
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.numLabel.text = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override var isSelected: Bool{
        willSet{
            super.isSelected = newValue
            if newValue {
                self.backgroundColor = .systemGray
            }else {
                self.backgroundColor = .systemBackground
            }
        }
    }
}
