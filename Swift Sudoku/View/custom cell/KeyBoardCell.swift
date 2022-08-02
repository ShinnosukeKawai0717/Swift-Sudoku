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
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        layer.cornerRadius = layer.frame.size.height / 2
        contentView.addSubview(numLabel)
    }
    
    func configure(with number: String) {
        DispatchQueue.main.async {
            NSLayoutConstraint.activate([
                self.numLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
                self.numLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
            ])
            self.numLabel.text = number
        }
    }
    
    func changeNoteImage(with imageName: String) {
        DispatchQueue.main.async {
            self.contentView.addSubview(self.imageView)
            NSLayoutConstraint.activate([
                self.imageView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
                self.imageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
            ])
            self.imageView.image = UIImage(systemName: imageName)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.numLabel.text = nil
        self.imageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    override var isSelected: Bool {
        willSet {
            self.backgroundColor = .systemGray.withAlphaComponent(0.7)
        }
        didSet {
            self.backgroundColor = .systemBackground
        }
    }
}
