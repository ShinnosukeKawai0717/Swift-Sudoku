//
//  SudokuGridView.swift
//  Sudoku
//
//  Created by Shinnosuke Kawai on 7/12/22.
//

import Foundation
import UIKit

class SudokuGridView: UIView {
    
    private let gridCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        collectionview.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionview.backgroundColor = .clear
        collectionview.allowsSelection = false
        return collectionview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        gridCollectionView.delegate = self
        gridCollectionView.dataSource = self
        addSubview(gridCollectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            gridCollectionView.topAnchor.constraint(equalTo: topAnchor),
            gridCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gridCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gridCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

extension SudokuGridView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.layer.borderColor = UIColor.systemGray.cgColor
        cell.layer.borderWidth = 0.3
        addBorderAt(indexPath, cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/9, height: collectionView.frame.width/9)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private func addBorderAt(_ indexPath: IndexPath, _ cell: UICollectionViewCell) {
        if indexPath.row == 2 || indexPath.row == 5 || indexPath.row == 8 {
            cell.addBorder(toSide: .right, withColor: .black, andThickness: 3)
        }
        if indexPath.row == 0 {
            cell.addBorder(toSide: .left, withColor: .black, andThickness: 3)
        }
        else if indexPath.row == 3 || indexPath.row == 6 {
            cell.addBorder(toSide: .left, withColor: .black, andThickness: 3)
        }
        if indexPath.section == 2 || indexPath.section == 5 || indexPath.section == 8 {
            cell.addBorder(toSide: .bottom, withColor: .black, andThickness: 3)
        }
        
        if indexPath.section == 3 || indexPath.section == 6{
            cell.addBorder(toSide: .top, withColor: .black, andThickness: 3)
        }
        else if indexPath.section == 0 {
            cell.addBorder(toSide: .top, withColor: .black, andThickness: 3)
        }
    }
}
