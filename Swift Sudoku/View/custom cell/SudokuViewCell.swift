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
    
//    private let noteView: NoteView = {
//        let view = NoteView()
//        view.backgroundColor = .clear
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
//        contentView.addSubview(noteView)
        contentView.addSubview(cellLabel)
    }
    
    public func configureLabel(with number: String, textColor: UIColor, backGroundColor: UIColor) {
        DispatchQueue.main.async {
            self.cellLabel.backgroundColor = backGroundColor
            self.cellLabel.text = number
            self.cellLabel.textColor = textColor
        }
    }
    
    public func showNoteView() {
//        DispatchQueue.main.async {
//            self.contentView.addSubview(self.noteView)
//            NSLayoutConstraint.activate([
//                self.noteView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
//                self.noteView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
//                self.noteView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
//                self.noteView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
//            ])
//        }
    }
    
    public func configureNote(with number: String) {
//        noteView.configure(with: number)
    }
    
    public func hideNoteView() {
//        DispatchQueue.main.async {
//            self.noteView.removeFromSuperview()
//            self.contentView.addSubview(self.cellLabel)
//        }
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
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
