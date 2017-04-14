//
//  UIView+Gradients.swift
//  SoManyGames
//
//  Created by Luke Charman on 01/04/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {

    private let h = CAGradientLayer()
    private let v = CAGradientLayer()

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        isOpaque = false
        backgroundColor = .clear
        isUserInteractionEnabled = false

        setUpGradients()
    }

    func resize() {
        h.frame = bounds
        v.frame = bounds
    }

    private func setUpGradients() {
        h.frame = bounds
        v.frame = bounds

        h.colors = [UIColor.black.withAlphaComponent(0.2).cgColor, UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.2).cgColor]
        v.colors = [UIColor.black.withAlphaComponent(0.3).cgColor, UIColor.clear.cgColor]

        h.startPoint = CGPoint(x: 0, y: 0)
        h.endPoint = CGPoint(x: 1, y: 0)

        v.startPoint = CGPoint(x: 0, y: 1)
        v.endPoint = CGPoint(x: 0, y: 0)

        layer.addSublayer(h)
        layer.addSublayer(v)
    }

}
