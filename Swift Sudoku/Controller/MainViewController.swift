//
//  ViewController.swift
//  Sudoku
//
//  Created by Shinnosuke Kawai on 6/25/22.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
    
    private let sudokuVC = SudokuBoardViewController()
    private let keyBoardVC = KeyboardViewController()
    private let favoriteListVC = FavoriteListViewController()
    private let sudokuGridView = SudokuGridView()
    private let titles: [String] = ["Easy", "Medium", "Hard"]
    private let diffPickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    private let timerView: TimerView = {
        let view = TimerView()
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
        view.addSubview(sudokuGridView)
        view.addSubview(sudokuVC.view)
        view.addSubview(keyBoardVC.view)
        view.addSubview(diffPickerView)
        addConstraints()
        initNavigationItems()
    }
    
    @objc func saveDidTap() {
        let difficulty = self.title ?? "easy"
        sudokuVC.saveFavorite(difficulty: difficulty)
    }
    
    @objc func historyDidTap() {
        navigationController?.pushViewController(favoriteListVC, animated: true)
    }
    
    private func initNavigationItems() {
        var configuration = UIImage.SymbolConfiguration(hierarchicalColor: .systemPink)
        let heart_fill = UIImage(systemName: "heart.fill", withConfiguration: configuration)
        
        configuration = UIImage.SymbolConfiguration(hierarchicalColor: .systemGray)
        let history = UIImage(systemName: "bookmark", withConfiguration: configuration)
        
        let saveItem = UIBarButtonItem(image: heart_fill, style: .plain, target: self, action: #selector(saveDidTap))
        let historyItem = UIBarButtonItem(image: history, style: .plain, target: self, action: #selector(historyDidTap))
        
        self.navigationItem.rightBarButtonItems = [historyItem, saveItem]
    }
    
    private func addConstraints() {
        
        NSLayoutConstraint.activate([
            timerView.topAnchor.constraint(equalTo: navigationController!.navigationBar.bottomAnchor),
            timerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            timerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            timerView.heightAnchor.constraint(equalToConstant: view.frame.size.height/20),
        ])
        
        // add constraints to sudokuVC
        NSLayoutConstraint.activate([
            sudokuVC.view.topAnchor.constraint(equalTo: timerView.bottomAnchor),
            sudokuVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            sudokuVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            sudokuVC.view.heightAnchor.constraint(equalToConstant: view.frame.height/2)
        ])
        
        NSLayoutConstraint.activate([
            sudokuGridView.topAnchor.constraint(equalTo: timerView.bottomAnchor),
            sudokuGridView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            sudokuGridView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            sudokuGridView.heightAnchor.constraint(equalToConstant: view.frame.height/2)
        ])
        
        // add constraints to diffPickerView
        NSLayoutConstraint.activate([
            diffPickerView.topAnchor.constraint(equalTo: sudokuVC.view.bottomAnchor),
            diffPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 5),
            diffPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -5),
            diffPickerView.heightAnchor.constraint(equalToConstant: view.frame.width/4)
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

extension MainViewController: SudokuBoardViewControllerDelegate {
    func timerShouldStart() {
        var second = 0
        var minutes = 0
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            if second == 60  {
                second = 0
                minutes += 1
            }
            let second_str = second < 10 ? "0\(second)" : "\(second)"
            let minu_str = minutes < 10 ? "0\(minutes)" : "\(minutes)"
            
            DispatchQueue.main.async {
                strongSelf.timerView.configure(text: "\(minu_str) : \(second_str)")
            }
            second += 1
        }.fire()
    }
}

extension MainViewController: FavoriteListViewControllerDelegate {
    func favoriteListViewController(_ vc: FavoriteListViewController, didSelecte favorite: Sudoku, at indexPath: IndexPath) {
        self.sudokuVC.reloadBoard(with: favorite, and: indexPath)
    }
}

extension MainViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return titles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return titles[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let diff = String(row + 1)
        let title = titles[row]
        self.title = title
        DispatchQueue.global(qos: .userInitiated).async {
            self.sudokuVC.generateSudoku(with: diff)
        }
    }
    
}
