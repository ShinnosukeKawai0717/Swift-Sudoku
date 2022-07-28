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
    func didMakeMistake()
    func resetMistakeCount()
}

class SudokuBoardViewController: UIViewController {
    
    private var newNote = ""
    private var noteDataSource = Array(repeating: Array(repeating: "", count: 3), count: 3)
    private var canEditNote = false
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
                if let sudokuCell = self.sudokuGridCollectionView.cellForItem(at: oldValue ?? IndexPath()) as? SudokuViewCell {
                    sudokuCell.contentView.backgroundColor = .clear
                }
                if let noteCell = self.sudokuGridCollectionView.cellForItem(at: oldValue ?? IndexPath()) as? NoteCell {
                    noteCell.contentView.backgroundColor = .clear
                }
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
        collectionview.register(SudokuViewCell.self, forCellWithReuseIdentifier: SudokuViewCell.identifier)
        collectionview.register(NoteCell.self, forCellWithReuseIdentifier: NoteCell.identifier)
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
        delegate?.resetMistakeCount()
    }
    
    public func reloadBoard(indexPath: IndexPath) {
        selectedIndex = nil
        guard let selectedSudoku = savedSudoku?[indexPath.row] else {
            return
        }
        self.unsolvedSudoku = selectedSudoku
        let unsolvedCopy = self.unsolvedSudoku.copy(with: nil) as! Sudoku
        DispatchQueue.global(qos: .background).async {
            if let solvedBord = self.sudokuManager.solve(sudoku: unsolvedCopy) {
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
        let guess = Int(letter)!
        if let selectedIndex = selectedIndex {
            if self.unsolvedSudoku.board[selectedIndex.row].columns[selectedIndex.section].isZero {
                if guess != self.solvedSudoku.board[selectedIndex.row].columns[selectedIndex.section].value {
                    delegate?.didMakeMistake()
                }
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
    
    public func activateNote() {
        canEditNote = !canEditNote
        if canEditNote {
            print("Note activated")
        }
        else {
            print("Note deactivated")
        }
    }
    
    public func modifyNote(with letter: String) {
        guard let selectedIndex = selectedIndex else {
            print("Cell is not selected")
            return
        }
        DispatchQueue.main.async {
            self.newNote = letter
            self.sudokuGridCollectionView.reloadItems(at: [selectedIndex])
        }
    }
    
    public func giveHint() {
        selectedIndex = nil
        var indePaths = Set<IndexPath>()
        for row in 0..<9 {
            for colum in 0..<9 {
                if self.unsolvedSudoku.board[row].columns[colum].value == 0 {
                    indePaths.insert(IndexPath(row: row, section: colum))
                }
            }
        }
        let ramdomIndexPath = indePaths.randomElement()!
        let hint = solvedSudoku.board[ramdomIndexPath.row].columns[ramdomIndexPath.section].value
        
        databaseManager.updateForHint(sudoku: unsolvedSudoku, newValue: hint, at: ramdomIndexPath)
        DispatchQueue.main.async {
            self.sudokuGridCollectionView.reloadItems(at: [ramdomIndexPath])
        }
    }
    
    public func solve() {
        selectedIndex = nil
        guard let solvedCopy = solvedSudoku.copy(with: nil) as? Sudoku else {
            return
        }
        for row in 0..<9 {
            for column in 0..<9 {
                solvedCopy.board[row].columns[column].isHint = unsolvedSudoku.board[row].columns[column].isHint
            }
        }
        self.unsolvedSudoku = solvedCopy
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
        return self.unsolvedSudoku.board[section].columns.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if canEditNote {
            let noteCell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteCell.identifier, for: indexPath) as! NoteCell
            print(noteCell)
            if selectedIndex != nil {
                noteCell.contentView.backgroundColor = .systemGray.withAlphaComponent(0.6)
            }
            print("can edit note")
            if let noteIndex = NoteCell.indexDict[newNote] {
                if noteDataSource[noteIndex.row][noteIndex.section] != newNote {
                    noteDataSource[noteIndex.row][noteIndex.section] = newNote
                }else {
                    noteDataSource[noteIndex.row][noteIndex.section] = ""
                }
                noteCell.configure(note: noteDataSource)
            }
            return noteCell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SudokuViewCell.identifier, for: indexPath) as! SudokuViewCell
        if selectedIndex != nil {
            cell.contentView.backgroundColor = .systemGray.withAlphaComponent(0.6)
        }
        let number = self.unsolvedSudoku.board[indexPath.row].columns[indexPath.section].value
        let isHint = self.unsolvedSudoku.board[indexPath.row].columns[indexPath.section].isHint
        
        if isHint {
            if number != 0 {
                cell.configureLabel(with: String(number), textColor: .systemRed, backGroundColor: .secondarySystemBackground.withAlphaComponent(0.4))
                return cell
            }
            cell.configureLabel(with: "", textColor: .systemRed, backGroundColor: .clear)
            return cell
        }
        else {
            if number != 0 {
                cell.configureLabel(with: String(number), textColor: .systemCyan, backGroundColor: .secondarySystemBackground.withAlphaComponent(0.4))
                return cell
            }
            cell.configureLabel(with: "", textColor: .systemCyan, backGroundColor: .clear)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.newNote = ""
        self.noteDataSource.removeAll()
        self.noteDataSource = Array(repeating: Array(repeating: "", count: 3), count: 3)
        print(self.noteDataSource)
        self.selectedIndex = indexPath
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
