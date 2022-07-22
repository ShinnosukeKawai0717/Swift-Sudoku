//
//  FavoriteListViewController.swift
//  Sudoku
//
//  Created by Shinnosuke Kawai on 7/11/22.
//

import UIKit
import RealmSwift
import SwiftUI
import ProgressHUD

protocol FavoriteListViewControllerDelegate: AnyObject {
    func favoriteListViewController(_ vc: FavoriteListViewController, didSelecte favorite: Sudoku, at indexPath: IndexPath)
}
class FavoriteListViewController: UIViewController {
    
    weak var delegate: FavoriteListViewControllerDelegate?
    private let dataManager = DatabaseManager()
    private var favorites: Results<Sudoku>? {
        didSet {
            DispatchQueue.main.async {
                self.listTableView.reloadData()
            }
        }
    }
    private let listTableView: UITableView = {
        let table = UITableView()
        table.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(listTableView)
        listTableView.delegate = self
        listTableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        self.favorites = dataManager.retrive()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.activate([
            listTableView.topAnchor.constraint(equalTo: view.topAnchor),
            listTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension FavoriteListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.identifier, for: indexPath) as! FavoriteCell
        if let favorite = favorites?[indexPath.row] as? Sudoku {
            cell.configure(favorite: favorite)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let favorite = favorites?[indexPath.row] as? Sudoku {
            delegate?.favoriteListViewController(self, didSelecte: favorite, at: indexPath)
        }
        self.navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(50)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            if let favoriteToDelete = favorites?[indexPath.row] {
                dataManager.delete(favorite: favoriteToDelete)
                DispatchQueue.main.async {
                    tableView.deleteRows(at: [indexPath], with: .left)
                }
            }
        }
    }
}
