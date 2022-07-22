//
//  FavoriteCell.swift
//  Sudoku
//
//  Created by Shinnosuke Kawai on 7/11/22.
//

import UIKit

class FavoriteCell: UITableViewCell {
    
    static let identifier = "FavoriteCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let difficultyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public func configure(favorite: Sudoku) {
        DispatchQueue.main.async {
            self.nameLabel.text = favorite.name
            switch favorite.diff.rawValue {
            case "easy":
                self.difficultyLabel.textColor = .systemGreen
            case "medium":
                self.difficultyLabel.textColor = .systemYellow
            case "hard":
                self.difficultyLabel.textColor = .systemRed
            default:
                break
            }
            self.difficultyLabel.text = favorite.diff.rawValue
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(nameLabel)
        contentView.addSubview(difficultyLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            nameLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width/1.5)
        ])
        
        NSLayoutConstraint.activate([
            difficultyLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            difficultyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            difficultyLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            difficultyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
