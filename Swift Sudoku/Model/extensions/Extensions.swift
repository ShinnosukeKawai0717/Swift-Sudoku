//
//  Extensions.swift
//  Sudoku
//
//  Created by Shinnosuke Kawai on 6/26/22.
//

import UIKit

extension UIView {

    func addBorder(toSide side: UIRectEdge, withColor color: UIColor, andThickness thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        switch side {
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
        case .right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.height, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: UIScreen.main.bounds.width, height: thickness)
        default:
            break
        }
        layer.addSublayer(border)
    }
}

extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

public func ==(lhs: CGPoint, rhs: CGPoint) -> Bool {
    return lhs.equalTo(rhs)
}

extension UINavigationController {
    func pushViewControllerFromLeft(_ vc: UIViewController) {
        let transition = CATransition()
        transition.type = .push
        transition.duration = 0.5
        transition.subtype = .fromLeft
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        pushViewController(vc, animated: false)
    }
    
    func popViewControllerToLeft() {
        let transition = CATransition()
        transition.type = .push
        transition.duration = 0.5
        transition.subtype = .fromRight
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        popViewController(animated: false)
    }
    
}
