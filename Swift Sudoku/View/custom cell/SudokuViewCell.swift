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
        label.isHidden = false
        return label
    }()
    
    private let noteView: NoteView = {
        let view = NoteView()
        view.backgroundColor = .clear
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        contentView.addSubview(cellLabel)
        self.contentView.addSubview(self.noteView)
        
    }
    
    public func configureLabel(with number: String, textColor: UIColor, backGroundColor: UIColor) {
        DispatchQueue.main.async {
            self.cellLabel.backgroundColor = backGroundColor
            self.cellLabel.text = number
            self.cellLabel.textColor = textColor
        }
    }
    
    public func showNoteView(for letter: String) {
        self.cellLabel.isHidden = true
        self.noteView.isHidden = false
        
        noteView.configure(with: letter)
    }
    
    public func hideNoteView() {
        self.cellLabel.isHidden = false
        self.noteView.isHidden = true
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellLabel.backgroundColor = nil
        self.cellLabel.text = nil
        self.cellLabel.textColor = nil
        self.contentView.backgroundColor = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            cellLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        NSLayoutConstraint.activate([
            noteView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            noteView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -3),
            noteView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 3),
            noteView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
