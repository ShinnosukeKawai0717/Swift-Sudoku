//
//  TutorialViewController.swift
//  Swift Sudoku
//
//  Created by Shinnosuke Kawai on 7/23/22.
//

import UIKit

class TutorialViewController: UIViewController {
    
    lazy var barButton = UIBarButtonItem(title: "Back >", style: .done, target: self, action: #selector(goBackBarButtonTapped))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpNavigationBar()
    }
    func setUpNavigationBar() {
        navigationItem.hidesBackButton = true
        navigationItem.setRightBarButton(barButton, animated: true)
    }
    
    @objc func goBackBarButtonTapped() {
        navigationController?.popViewControllerToLeft()
    }
}
