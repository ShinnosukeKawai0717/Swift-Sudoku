//
//  NoteCell.swift
//  Swift Sudoku
//
//  Created by Shinnosuke Kawai on 7/26/22.
//

import UIKit

class NoteCell: UICollectionViewCell {
    
    static let identifier = "NoteCell"
    
    private var datasource: [[String]] = Array(repeating: Array(repeating: "", count: 3), count: 3)
    
    static let indexDict = [
        "1" : IndexPath(row: 0, section: 0), "2" : IndexPath(row: 0, section: 1), "3" : IndexPath(row: 0, section: 2),
        "4" : IndexPath(row: 1, section: 0), "5" : IndexPath(row: 1, section: 1), "6" : IndexPath(row: 1, section: 2),
        "7" : IndexPath(row: 2, section: 0), "8" : IndexPath(row: 2, section: 1), "9" : IndexPath(row: 2, section: 2)
    ]
    
    private let noteCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(NumCell.self, forCellWithReuseIdentifier: NumCell.identifier)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        noteCollectionView.delegate = self
        noteCollectionView.dataSource = self
    }
    
    func configure(note: [[String]]) {
        DispatchQueue.main.async {
            self.datasource = note
            self.noteCollectionView.reloadData()
        }
        datasource.removeAll()
        datasource = Array(repeating: Array(repeating: "", count: 3), count: 3)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(noteCollectionView)
        NSLayoutConstraint.activate([
            noteCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            noteCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            noteCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            noteCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NoteCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.datasource[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NumCell.identifier, for: indexPath) as? NumCell else {
            fatalError()
        }
        print(datasource[indexPath.section][indexPath.row])
        cell.configure(text: datasource[indexPath.section][indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var top: CGFloat = 0
        if section == 0 {
            top = (contentView.frame.height - ((contentView.frame.size.width/4)*3)) / 2
        }
        return UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.contentView.frame.size.width/4, height: self.contentView.frame.size.width/4)
    }
}
