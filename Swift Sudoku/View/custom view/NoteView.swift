//
//  NoteView.swift
//  Swift Sudoku
//
//  Created by Shinnosuke Kawai on 7/24/22.
//

import Foundation
import UIKit
import SwiftUI

class NoteView: UIView {
    
    private var notes: [[String]] = [
        ["", "", ""],
        ["", "", ""],
        ["", "", ""]
    ] {
        didSet {
            DispatchQueue.main.async {
                self.noteView.reloadData()
            }
        }
    }
    
    private let indexDict = [
        "1" : IndexPath(row: 0, section: 0), "2" : IndexPath(row: 0, section: 1), "3" : IndexPath(row: 0, section: 2),
        "4" : IndexPath(row: 1, section: 0), "5" : IndexPath(row: 1, section: 1), "6" : IndexPath(row: 1, section: 2),
        "7" : IndexPath(row: 2, section: 0), "8" : IndexPath(row: 2, section: 1), "9" : IndexPath(row: 2, section: 2)
    ]
    
    private let noteView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(NoteCell.self, forCellWithReuseIdentifier: NoteCell.identifier)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(noteView)
        noteView.delegate = self
        noteView.dataSource = self
    }
    func configure(with newNote: String) {
        let indexPath = indexDict[newNote]!
        if notes[indexPath.row][indexPath.section] != newNote {
            notes[indexPath.row][indexPath.section] = newNote
        }
        else {
            notes[indexPath.row][indexPath.section] = ""
        }
    }
    override func layoutSubviews() {
        noteView.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NoteView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteCell.identifier, for: indexPath) as? NoteCell else {
            fatalError()
        }
        cell.configure(note: notes[indexPath.section][indexPath.row])
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.size.width/3, height: frame.size.width/3)
    }
}
