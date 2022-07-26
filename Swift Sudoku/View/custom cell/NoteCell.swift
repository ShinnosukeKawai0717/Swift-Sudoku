//
//  NoteCell.swift
//  Swift Sudoku
//
//  Created by Shinnosuke Kawai on 7/26/22.
//

import UIKit

class NoteCell: UICollectionViewCell {
    
    static let identifier = "NoteCell"
    
    private let noteLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .lightGray
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var hasNote: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(noteLabel)
        contentView.backgroundColor = .clear
    }
    
    func configure(note: String) {
        DispatchQueue.main.async {
            self.noteLabel.text = note
        }
    }
    
    override func prepareForReuse() {
        self.noteLabel.text = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        noteLabel.frame = bounds
    }
    
}
