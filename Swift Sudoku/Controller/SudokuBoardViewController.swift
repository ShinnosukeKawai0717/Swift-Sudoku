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
    private var noteDataSource = Array(repeating: "", count: 9)
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
//            guard let newValue = newValue else {
//                return
//            }
//            self.sudokuGridCollectionView.reloadItems(at: [newValue])
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
        collectionview.allowsMultipleSelection = true
        return collectionview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppUtility.lockOrientation(.portrait)
        sudokuGridCollectionView.delegate = self
        sudokuGridCollectionView.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.generateSudoku(with: "1")
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
                strongSelf.delegate?.timerShouldStart()
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
            
        }
        else {
        
        }
    }
    
    public func modifyNote(with letter: String) {
        guard let selectedIndex = selectedIndex else {
            print("Cell is not selected")
            return
        }
        DispatchQueue.main.async {
            self.newNote = letter
            self.databaseManager.updateNote(sudoku: self.unsolvedSudoku, newNote: letter, at: selectedIndex)
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
            guard let noteCell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteCell.identifier, for: indexPath) as? NoteCell else {
                fatalError()
            }
            if noteDataSource.contains(newNote) {
                noteDataSource.replace(newNote, with: "")
            }
            else {
                noteDataSource.append(newNote)
            }
            noteCell.configure(with: noteDataSource)
            return noteCell
        }
        
        let sudokuCell = collectionView.dequeueReusableCell(withReuseIdentifier: SudokuViewCell.identifier, for: indexPath) as! SudokuViewCell
        let number = self.unsolvedSudoku.board[indexPath.row].columns[indexPath.section].value
        let isHint = self.unsolvedSudoku.board[indexPath.row].columns[indexPath.section].isHint
        if isHint {
            if number != 0 {
                sudokuCell.configureLabel(with: String(number), textColor: .systemRed, backGroundColor: .secondarySystemBackground.withAlphaComponent(0.7))
                return sudokuCell
            }
            sudokuCell.configureLabel(with: "", textColor: .systemRed, backGroundColor: .clear)
            return sudokuCell
        }
        else {
            if number != 0 {
                sudokuCell.configureLabel(with: String(number), textColor: .systemCyan, backGroundColor: .secondarySystemBackground.withAlphaComponent(0.7))
                return sudokuCell
            }
            sudokuCell.configureLabel(with: "", textColor: .systemCyan, backGroundColor: .clear)
            return sudokuCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            let localRow = indexPath.row - indexPath.row % 3
            let localColumn = indexPath.section - indexPath.section % 3
            // unhighlight all the cells that are previuslly highlighted if ther are any
            if let indexPaths = collectionView.indexPathsForSelectedItems {
                for indexPath in indexPaths {
                    collectionView.deselectItem(at: indexPath, animated: false)
                }
            }
            // highlight corresponding row and column
            for i in 0..<9 {
                collectionView.selectItem(at: IndexPath(row: i, section: indexPath.section), animated: false, scrollPosition: .top)
                collectionView.selectItem(at: IndexPath(row: indexPath.row, section: i), animated: false, scrollPosition: .top)
            }
            // highligh corresponding sub grid
            for i in localRow..<localRow+3 {
                for j in localColumn..<localColumn+3 {
                    collectionView.selectItem(at: IndexPath(row: i, section: j), animated: false, scrollPosition: .top)
                }
            }
        }
        self.newNote = ""
        self.noteDataSource.removeAll()
        self.selectedIndex = indexPath
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            guard let selectedIndexs = collectionView.indexPathsForSelectedItems else {
                return
            }
            // unhighlight all the cells that are previuslly highlighted if ther are any
            for selectedIndex in selectedIndexs {
                collectionView.deselectItem(at: selectedIndex, animated: false)
            }
            let localRow = indexPath.row - indexPath.row % 3
            let localColumn = indexPath.section - indexPath.section % 3
            // highlight corresponding row and column
            for i in 0..<9 {
                collectionView.selectItem(at: IndexPath(row: i, section: indexPath.section), animated: false, scrollPosition: .top)
                collectionView.selectItem(at: IndexPath(row: indexPath.row, section: i), animated: false, scrollPosition: .top)
            }
            // highligh corresponding sub grid
            for i in localRow..<localRow+3 {
                for j in localColumn..<localColumn+3 {
                    collectionView.selectItem(at: IndexPath(row: i, section: j), animated: false, scrollPosition: .top)
                }
            }
        }
        self.newNote = ""
        self.noteDataSource.removeAll()
        self.selectedIndex = indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width/9, height: self.view.frame.size.width/9)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.unsolvedSudoku.board.count
    }
   
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
    
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}
