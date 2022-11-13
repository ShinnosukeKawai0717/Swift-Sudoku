//
//  ViewController.swift
//  Sudoku
//
//  Created by Shinnosuke Kawai on 6/25/22.
//

import UIKit
import RealmSwift
import ProgressHUD

class MainViewController: UIViewController {
    
    private var isNoteActive = false
    private let sudokuVC = SudokuBoardViewController()
    private let keyBoardVC = KeyboardViewController()
    private let favoriteListVC = FavoriteListViewController()
    private let tutorialVC = TutorialViewController()
    private let titles: [String] = ["Easy", "Medium", "Hard"]
    private let diffPickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .secondarySystemBackground
        picker.layer.masksToBounds = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    private let timerView: TimerView = {
        let view = TimerView(frame: .zero, time: Time())
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        keyBoardVC.delegate = self
        sudokuVC.delegate = self
        diffPickerView.delegate = self
        diffPickerView.dataSource = self
        favoriteListVC.delegate = self
        AppUtility.lockOrientation(.portrait)
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initMainView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
    }
    
    private func initMainView() {
        title = "Sudoku"
        
        addChild(sudokuVC)
        sudokuVC.didMove(toParent: self)
        
        addChild(keyBoardVC)
        keyBoardVC.didMove(toParent: self)
        
        view.addSubview(timerView)
        view.addSubview(sudokuVC.view)
        view.addSubview(keyBoardVC.view)
        view.addSubview(diffPickerView)
        addConstraints()
        initNavigationItems()
    }
    
    private func initNavigationItems() {
        var configuration = UIImage.SymbolConfiguration(hierarchicalColor: .systemPink)
        let heart_fill = UIImage(systemName: "heart.fill", withConfiguration: configuration)
        
        configuration = UIImage.SymbolConfiguration(hierarchicalColor: .systemGray)
        let history = UIImage(systemName: "bookmark", withConfiguration: configuration)
        
        let help = UIImage(systemName: "questionmark.circle", withConfiguration: configuration)
        
        let saveItem = UIBarButtonItem(image: heart_fill, style: .plain, target: self, action: #selector(saveDidTap))
        let historyItem = UIBarButtonItem(image: history, style: .plain, target: self, action: #selector(historyDidTap))
        let helpItem = UIBarButtonItem(image: help, style: .plain, target: self, action: #selector(helpDidTap))
        self.navigationItem.rightBarButtonItems = [historyItem, saveItem]
        self.navigationItem.leftBarButtonItem = helpItem
    }
    
    @objc func saveDidTap() {
        let difficulty = self.title ?? "easy"
        sudokuVC.saveFavorite(difficulty: difficulty, currentTime: timerView.getCurrentTime())
        timerView.stopTimer()
    }
    
    @objc func historyDidTap() {
        navigationController?.pushViewController(favoriteListVC, animated: true)
    }
    
    @objc func helpDidTap() {
        navigationController?.pushViewControllerFromLeft(tutorialVC)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            timerView.topAnchor.constraint(equalTo: navigationController!.navigationBar.bottomAnchor),
            timerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            timerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            timerView.heightAnchor.constraint(equalToConstant: 30),
        ])
        
        // add constraints to sudokuVC
        NSLayoutConstraint.activate([
            sudokuVC.view.topAnchor.constraint(equalTo: timerView.bottomAnchor),
            sudokuVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sudokuVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sudokuVC.view.heightAnchor.constraint(equalToConstant: view.frame.height/2)
        ])
        
        // add constraints to diffPickerView
        NSLayoutConstraint.activate([
            diffPickerView.topAnchor.constraint(equalTo: sudokuVC.view.bottomAnchor),
            diffPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            diffPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            diffPickerView.heightAnchor.constraint(equalToConstant: view.frame.width/3.4)
        ])
        
        // add constrains to keyboardVC
        NSLayoutConstraint.activate([
            keyBoardVC.view.topAnchor.constraint(equalTo: diffPickerView.bottomAnchor),
            keyBoardVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            keyBoardVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            keyBoardVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension MainViewController: KeyboardViewControllerDelegate {
    func keyboardViewController(_ vc: KeyboardViewController, didTapKey letter: String) {
        if letter == "Note" {
            isNoteActive = !isNoteActive
            sudokuVC.activateNote()
        }
        else if isNoteActive {
            sudokuVC.modifyNote(with: letter)
        }
        else {
            switch letter.lowercased() {
            case "ans":
                sudokuVC.solve()
            case "hint":
                sudokuVC.giveHint()
            default:
                sudokuVC.modifyBoard(with: letter)
            }
        }
    }
}

extension MainViewController: SudokuBoardViewControllerDelegate {
    func timerShouldStart() {
        self.timerView.startTimer()
    }
    func timerShouldRestart() {
        DispatchQueue.main.async {
            self.timerView.restart()
        }
    }
    func didMakeMistake() {
        self.timerView.incrementMistake()
    }
    func resetMistakeCount() {
        self.timerView.resetMistakeCounter()
    }
}

extension MainViewController: FavoriteListViewControllerDelegate {
    func favoriteListViewController(_ vc: FavoriteListViewController, didSelecte favorite: Sudoku, at indexPath: IndexPath) {
        self.sudokuVC.reloadBoard(indexPath: indexPath)
    }
}

extension MainViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return titles.count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return CGFloat(45)
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return titles[row]
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let rowHeight = pickerView.rowSize(forComponent: component).height
        let width = self.view.frame.width - 100
        let height = rowHeight-10
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        let label: UILabel = {
            let label = UILabel(frame: myView.frame)
            label.layer.masksToBounds = true
            label.backgroundColor = .tintColor.withAlphaComponent(0.3)
            label.textAlignment = .center
            label.numberOfLines = 0
            label.layer.cornerRadius = height/2
            label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
            return label
        }()
        
        if row == 0 {
            label.textColor = .systemGreen
            label.text = "Easy"
        }
        else if row == 1 {
            label.textColor = .systemYellow
            label.text = "Medium"
        }
        else {
            label.textColor = .systemRed
            label.text = "Hard"
        }
        myView.addSubview(label)
        return myView
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let diff = String(row + 1)
        let title = titles[row]
        self.title = title
        ProgressHUD.show("Generating sudoku...", interaction: false)
        self.timerView.resetTimer()
        self.sudokuVC.generateSudoku(with: diff)
    }
}
