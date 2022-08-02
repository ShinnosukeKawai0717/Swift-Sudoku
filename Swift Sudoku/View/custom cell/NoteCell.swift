//
//  NoteCell.swift
//  Swift Sudoku
//
//  Created by Shinnosuke Kawai on 7/26/22.
//

import UIKit

class NoteCell: UICollectionViewCell {
    
    static let identifier = "NoteCell"
    private var dataSource = Array(repeating: "", count: 9)
    private var numLabels = [UILabel]()
    
    private let mainStackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.axis = .vertical
        view.alignment = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let topSView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.distribution = .fillEqually
        view.axis = .horizontal
        return view
    }()
    private let middleSView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.axis = .horizontal
        view.alignment = .center
        return view
    }()
    private let bottomSView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.axis = .horizontal
        view.alignment = .center
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpNumLabels()
        setUpStackViews()
    }
    
    func configure(with notes: [String]) {
        for note in notes {
            if let index = Int(note) {
                DispatchQueue.main.async {
                    self.numLabels[index-1].text = note
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectedBackgroundView = nil
        for numLabel in numLabels {
            numLabel.text = nil
        }
    }
    
    private func setUpNumLabels() {
        for _ in 0..<9 {
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = .center
            label.textColor = .systemGray
            label.font = UIFont.systemFont(ofSize: 12)
            numLabels.append(label)
        }
    }
    private func setUpStackViews() {
        for i in 0..<numLabels.count/3 {
            topSView.addArrangedSubview(numLabels[i])
        }
        for i in numLabels.count/3..<(numLabels.count/3)+3 {
            middleSView.addArrangedSubview(numLabels[i])
        }
        for i in (numLabels.count/3)+3..<numLabels.count {
            bottomSView.addArrangedSubview(numLabels[i])
        }
        mainStackView.addArrangedSubview(topSView)
        mainStackView.addArrangedSubview(middleSView)
        mainStackView.addArrangedSubview(bottomSView)
        contentView.addSubview(mainStackView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addConstrainsToSVs()
    }
    
    private func addConstrainsToSVs() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
        ])
        self.selectedBackgroundView = {
            let view = UIView()
            view.frame = bounds
            view.backgroundColor = .systemGray.withAlphaComponent(0.3)
            return view
        }()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
