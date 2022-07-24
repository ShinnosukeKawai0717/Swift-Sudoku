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
            if number == "Note" {
                self.numLabel.removeFromSuperview()
                self.contentView.addSubview(self.imageView)
                NSLayoutConstraint.activate([
                    self.imageView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
                    self.imageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
                ])
                self.imageView.image = UIImage(systemName: "pencil")
            }
            else {
                NSLayoutConstraint.activate([
                    self.numLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
                    self.numLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
                ])
                self.numLabel.text = number
            }
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
