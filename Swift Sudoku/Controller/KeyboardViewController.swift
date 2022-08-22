//
//  KeybordViewController.swift
//  Sudoku
//
//  Created by Shinnosuke Kawai on 6/25/22.
//

import UIKit

protocol KeyboardViewControllerDelegate: AnyObject {
    func keyboardViewController(_ vc: KeyboardViewController, didTapKey letter: String)
}

class KeyboardViewController: UIViewController {
    
    weak var delegate: KeyboardViewControllerDelegate?
    
    private let keys = [["1", "2", "3", "4", "5"], ["6", "7", "8", "9"], ["Hint", "Ans", "Note"]]
    
    private var isNoteActive = false {
        didSet {
            DispatchQueue.main.async {
                self.keyboardCollectionView.reloadItems(at: [IndexPath(row: 2, section: 2)])
            }
        }
    }
    
    private let keyboardCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(KeyBoardCell.self, forCellWithReuseIdentifier: KeyBoardCell.identifier)
        view.backgroundColor = .secondarySystemBackground
        view.isScrollEnabled = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray.cgColor
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        AppUtility.lockOrientation(.portrait)
        view.translatesAutoresizingMaskIntoConstraints = false
        keyboardCollectionView.delegate = self
        keyboardCollectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(keyboardCollectionView)
        NSLayoutConstraint.activate([
            keyboardCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            keyboardCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension KeyboardViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return keys[section].count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KeyBoardCell.identifier, for: indexPath) as? KeyBoardCell else {
            fatalError()
        }
        let key = keys[indexPath.section][indexPath.row]
        if key == "Note" {
            if isNoteActive {
                cell.changeNoteImage(with: "pencil")
                return cell
            }
            cell.changeNoteImage(with: "pencil.slash")
            return cell
        }
                
        cell.configure(with: key)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.size.width - 20.0) / 5
        return CGSize(width: size, height: size/1.5)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return keys.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var left: CGFloat = 1
        var right: CGFloat = 1
        var top: CGFloat = 5
        let size: CGFloat = (collectionView.frame.size.width - 20)/5
        let count: CGFloat = CGFloat(collectionView.numberOfItems(inSection: section))
        
        let inset: CGFloat = (collectionView.frame.size.width - (size * count) - (count * 2))/2

        left = inset
        right = inset

        let cellHeight = (collectionView.frame.size.width - 20.0) / 7.5
        if section == 0 {
            top = (collectionView.frame.size.height - ((cellHeight*3) + 10)) / 2
        }
        return UIEdgeInsets(top: top, left: left, bottom: 0, right: right)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let tappedKey = keys[indexPath.section][indexPath.row]
        if tappedKey == "Note" {
            isNoteActive = !isNoteActive
        }
        delegate?.keyboardViewController(self, didTapKey: tappedKey)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}
