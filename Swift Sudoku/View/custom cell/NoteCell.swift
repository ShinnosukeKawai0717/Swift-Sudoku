//
//  NoteCell.swift
//  Swift Sudoku
//
//  Created by Shinnosuke Kawai on 7/26/22.
//

import UIKit

class NoteCell: UICollectionViewCell {
    
    static let identifier = "NoteCell"
    
    private var notes: [[String]] = [
        ["", "", ""],
        ["", "", ""],
        ["", "", ""]
    ]
    
    private let indexDict = [
        "1" : IndexPath(row: 0, section: 0), "2" : IndexPath(row: 0, section: 1), "3" : IndexPath(row: 0, section: 2),
        "4" : IndexPath(row: 1, section: 0), "5" : IndexPath(row: 1, section: 1), "6" : IndexPath(row: 1, section: 2),
        "7" : IndexPath(row: 2, section: 0), "8" : IndexPath(row: 2, section: 1), "9" : IndexPath(row: 2, section: 2)
    ]
    
//    private let noteLabel: UILabel = {
//        let label = UILabel()
//        label.numberOfLines = 0
//        label.textAlignment = .center
//        label.textColor = .lightGray
//        label.backgroundColor = .clear
//        label.font = UIFont.systemFont(ofSize: 10)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
    
    private let noteView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(NumCell.self, forCellWithReuseIdentifier: NumCell.identifier)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(noteView)
        noteView.delegate = self
        noteView.dataSource = self
    }
    
    func configure(note: String) {
        let indexPath = indexDict[note]!
        
        DispatchQueue.main.async {
//            guard let noteCell = self.noteView.cellForItem(at: indexPath) as? NoteCell else {
//                return
//            }
            print("noteView is reloaded")
            print(note)
            self.notes[indexPath.section][indexPath.row] = note
            self.noteView.reloadData()
        }
    }
    
    override func prepareForReuse() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        NSLayoutConstraint.activate([
            noteView.topAnchor.constraint(equalTo: contentView.topAnchor),
            noteView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            noteView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            noteView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
}

extension NoteCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NumCell.identifier, for: indexPath) as? NumCell else {
            fatalError()
        }
        cell.configure(text: notes[indexPath.section][indexPath.row])
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.size.width/3, height: frame.size.width/3)
    }
}
