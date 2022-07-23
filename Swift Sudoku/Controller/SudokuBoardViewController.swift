//
//  SudokuViewController.swift
//  Sudoku
//
//  Created by Shinnosuke Kawai on 6/25/22.
//

import ProgressHUD
import UIKit
import RealmSwift

protocol SudokuBoardViewControllerDelegate: AnyObject {
    func timerShouldStart()
    func timerShouldRestart()
}

class SudokuBoardViewController: UIViewController {
    
    private let toast = Toast(type: .info,
                              message: "The problem has been solved",
                              image: UIImage(systemName: "checkmark.circle.fill",
                                     withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemGreen)))
    weak var delegate: SudokuBoardViewControllerDelegate?
    private let sudokuManager = SudokuManager()
    private let databaseManager = DatabaseManager()
    private var savedSudoku: Results<Sudoku>?
    private var solvedSudoku: Sudoku = Sudoku()
    private var unsolvedSudoku: Sudoku = Sudoku() {
        didSet {
            DispatchQueue.main.async {
                self.sudokuGridCollectionView.reloadData()
            }
        }
    }
    private var selectedIndex: IndexPath? {
        willSet {
            guard let newIndex = newValue else {
                return
            }
            DispatchQueue.main.async {
                self.sudokuGridCollectionView.reloadItems(at: [newIndex])
            }
        }
        didSet {
            DispatchQueue.main.async {
                guard let formerSelectedCell = self.sudokuGridCollectionView.cellForItem(at: oldValue ?? IndexPath()) as? SudokuCollectionViewCell else {
                    return
                }
                formerSelectedCell.contentView.backgroundColor = .clear
            }
        }
    }
    
    private let sudokuGridCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        collectionview.allowsMultipleSelection = false
        collectionview.allowsSelection = true
        collectionview.register(SudokuCollectionViewCell.self, forCellWithReuseIdentifier: SudokuCollectionViewCell.identifier)
        collectionview.backgroundColor = .clear
        return collectionview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppUtility.lockOrientation(.portrait)
        sudokuGridCollectionView.delegate = self
        sudokuGridCollectionView.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        let queue = DispatchGroup()
        queue.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            self.generateSudoku(with: "1")
            queue.leave()
        }
        queue.notify(queue: .global(qos: .userInteractive)) {
            self.delegate?.timerShouldStart()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        savedSudoku = databaseManager.retrive()
        databaseManager.printRealmURL()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(sudokuGridCollectionView)
        addConstrains()
    }
    
    private func addConstrains() {
        // add constraints to collection view
        NSLayoutConstraint.activate([
            sudokuGridCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sudokuGridCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sudokuGridCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sudokuGridCollectionView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    public func generateSudoku(with diff: String) {
        selectedIndex = nil
        ProgressHUD.show()
        SudokuManager.shared.generate(diff: diff) { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let unsolvedSudoku):
                strongSelf.unsolvedSudoku = unsolvedSudoku
                ProgressHUD.dismiss()
                guard let copy = unsolvedSudoku.copy(with: nil) as? Sudoku else {
                    return
                }
                if let solvedOne = strongSelf.sudokuManager.solve(sudoku: copy) {
                    strongSelf.solvedSudoku = solvedOne
                    DispatchQueue.main.async {
                        let totastView = ToastView(toast: strongSelf.toast, frame: CGRect(x: 0, y: 0, width: strongSelf.view.frame.size.width/1.2, height: 60))
                        totastView.show(on: strongSelf.sudokuGridCollectionView)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
                ProgressHUD.showFailed("Something went wrong", interaction: true)
            }
        }
    }
    
    public func reloadBoard(indexPath: IndexPath) {
        selectedIndex = nil
        self.unsolvedSudoku = savedSudoku?[indexPath.row] ?? Sudoku()
        let copy = self.unsolvedSudoku.copy(with: nil) as! Sudoku
        DispatchQueue.global(qos: .background).async {
            if let solvedBord = self.sudokuManager.solve(sudoku: copy) {
                self.solvedSudoku = solvedBord
                DispatchQueue.main.async {
                    let totastView = ToastView(toast: self.toast, frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width/1.2, height: 60))
                    totastView.show(on: self.sudokuGridCollectionView)
                    ProgressHUD.dismiss()
                }
            }
        }
    }
    
    public func modifyBoard(with letter: String) {
        if let selectedIndex = selectedIndex {
            if self.unsolvedSudoku.board[selectedIndex.section].rowValues[selectedIndex.row].isZero {
                databaseManager.update(sudoku: self.unsolvedSudoku, newValue: Int(letter)!, at: selectedIndex)
                DispatchQueue.main.async {
                    self.sudokuGridCollectionView.reloadItems(at: [selectedIndex])
                }
            }
            else {
                print("cell has value")
            }
        } else {
            print("cell is not selected")
        }
    }
    
    public func giveHint() {
        selectedIndex = nil
        var indePaths = Set<IndexPath>()
        for row in 0..<9 {
            for colum in 0..<9 {
                if self.unsolvedSudoku.board[colum].rowValues[row].number == 0 {
                    indePaths.insert(IndexPath(row: row, section: colum))
                }
            }
        }
        let ramdomIndexPath = indePaths.randomElement()!
        let hint = solvedSudoku.board[ramdomIndexPath.section].rowValues[ramdomIndexPath.row].number
        
        databaseManager.updateForHint(sudoku: unsolvedSudoku, newValue: hint, at: ramdomIndexPath)
        DispatchQueue.main.async {
            self.sudokuGridCollectionView.reloadItems(at: [ramdomIndexPath])
        }
    }
    
    public func solve() {
        selectedIndex = nil
        self.unsolvedSudoku = solvedSudoku
    }
    
    public func saveFavorite(difficulty: String) {
        let uiAlert = UIAlertController(title: "New favorite", message: "Enter a name of this problem", preferredStyle: .alert)
        uiAlert.addTextField { textFeild in
            textFeild.placeholder = "Enter here..."
            textFeild.keyboardType = .emailAddress
            textFeild.autocapitalizationType = .sentences
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] action in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.timerShouldRestart()
        }
        let done = UIAlertAction(title: "Add", style: .default) { [weak self] action in
            guard let strongSelf = self else {
                return
            }
            let result = uiAlert.textFields![0].text
            strongSelf.unsolvedSudoku.name = result ?? "My problem"
            strongSelf.unsolvedSudoku.dateAdded = Date()
            strongSelf.databaseManager.save(newFavorite: strongSelf.unsolvedSudoku)
            strongSelf.delegate?.timerShouldRestart()
            strongSelf.databaseManager.printRealmURL()
        }
        
        uiAlert.addAction(done)
        uiAlert.addAction(cancel)
        
        self.present(uiAlert, animated: true)
    }
}

extension SudokuBoardViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.unsolvedSudoku.board[section].rowValues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SudokuCollectionViewCell.identifier, for: indexPath) as? SudokuCollectionViewCell else {
            fatalError()
        }
        if selectedIndex != nil {
            DispatchQueue.main.async {
                cell.contentView.backgroundColor = .secondaryLabel
            }
        }
        let number = self.unsolvedSudoku.board[indexPath.section].rowValues[indexPath.row].number
        let isHint = self.unsolvedSudoku.board[indexPath.section].rowValues[indexPath.row].isHint
        
        if isHint {
            cell.configureLabel(with: number == 0 ? "" : String(number), textColor: .systemRed)
            return cell
        }
        else {
            cell.configureLabel(with: number == 0 ? "" : String(number), textColor: .systemCyan)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SudokuCollectionViewCell else {
            fatalError()
        }
        DispatchQueue.main.async {
            cell.contentView.backgroundColor = .secondaryLabel
        }
        self.selectedIndex = indexPath
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SudokuCollectionViewCell else {
            return
        }
        print(cell)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.view.frame.size.width)/9, height: (self.view.frame.size.width)/9)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.unsolvedSudoku.board.count
    }
}
