//
//  ToastView.swift
//  Sudoku
//
//  Created by Shinnosuke Kawai on 7/20/22.
//

import UIKit

class ToastView: UIView {
    
    private let model: Toast
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBackground
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    init(toast: Toast, frame: CGRect) {
        self.model = toast
        super.init(frame: frame)
        addSubview(messageLabel)
        if model.image != nil {
            addSubview(imageView)
        }
        backgroundColor = .secondaryLabel
        clipsToBounds = true
        layer.cornerRadius = frame.size.height/2
        layer.masksToBounds = true
        configure()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        if model.image != nil {
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: topAnchor),
                imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
                imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 35),
                
                messageLabel.topAnchor.constraint(equalTo: topAnchor),
                messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                messageLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor),
                messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }
        else {
            messageLabel.frame = bounds
        }
    }
    private func configure() {
        DispatchQueue.main.async {
            self.messageLabel.text = self.model.message
            self.imageView.image = self.model.image
        }
    }
    public func show(on collectionView: UICollectionView) {
        let width = collectionView.frame.size.width / 1.5
        
        // starting position
        self.frame = CGRect(x: (collectionView.frame.size.width-width)/2, y: -60, width: width, height: 60)
        
        collectionView.addSubview(self)
        UIView.animate(withDuration: 0.4) {
            // move to this positon
            self.frame = CGRect(x: (collectionView.frame.size.width-width)/2, y: 10, width: width, height: 60)
        } completion: { done in
            if done {
                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                    UIView.animate(withDuration: 0.4) {
                        // move toast untill it is out of the screen
                        self.frame = CGRect(x: (collectionView.frame.size.width-width)/2, y: -60, width: width, height: 60)
                    } completion: { finished in
                        if finished {
                            self.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
