//
//  UIView+Gradients.swift
//  SoManyGames
//
//  Created by Luke Charman on 01/04/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import UIKit

extension UIView {

    func makeGradients() {
        let verticalLayer = CAGradientLayer()
        verticalLayer.frame = frame
        verticalLayer.colors = [UIColor(white: 0, alpha: 0.2).cgColor, UIColor.clear.cgColor]
        verticalLayer.startPoint = CGPoint(x: 0, y: 1)
        verticalLayer.endPoint = CGPoint(x: 0, y: 0)
        layer.addSublayer(verticalLayer)

        let horizontalLayer = CAGradientLayer()
        horizontalLayer.frame = frame
        horizontalLayer.colors = [UIColor(white: 0, alpha: 0.1).cgColor, UIColor.clear.cgColor, UIColor(white: 0, alpha: 0.25).cgColor]
        horizontalLayer.startPoint = CGPoint(x: 0, y: 0)
        horizontalLayer.endPoint = CGPoint(x: 1, y: 0)
        layer.addSublayer(horizontalLayer)
    }

}
