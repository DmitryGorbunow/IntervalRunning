//
//  UIView+Extension.swift
//  IntervalRunning
//
//  Created by Dmitry Gorbunow on 5/31/23.
//

import UIKit

extension UIView {
    func setShadow() {
       layer.shadowColor = UIColor.systemGray3.cgColor
       layer.shadowOpacity = 1
       layer.shadowOffset = .zero
       layer.shadowRadius = 3
    }
}
