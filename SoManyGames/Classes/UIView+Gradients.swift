//
//  UIView+Gradients.swift
//  SoManyGames
//
//  Created by Luke Charman on 01/04/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import UIKit

typealias RetroGradients = (horizontal: CAGradientLayer, vertical: CAGradientLayer)

extension UIView {

    func makeGradients() -> (horizontal: CAGradientLayer, vertical: CAGradientLayer) {
        let horizontalLayer = CAGradientLayer()
        horizontalLayer.frame = frame
        horizontalLayer.colors = [UIColor.black.withAlphaComponent(0.1).cgColor, UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.25).cgColor]
        horizontalLayer.startPoint = CGPoint(x: 0, y: 0)
        horizontalLayer.endPoint = CGPoint(x: 1, y: 0)
        layer.addSublayer(horizontalLayer)

        let verticalLayer = CAGradientLayer()
        verticalLayer.frame = frame
        verticalLayer.colors = [UIColor.black.withAlphaComponent(0.2).cgColor, UIColor.clear.cgColor]
        verticalLayer.startPoint = CGPoint(x: 0, y: 1)
        verticalLayer.endPoint = CGPoint(x: 0, y: 0)
        layer.addSublayer(verticalLayer)

        return (horizontalLayer, verticalLayer)
    }

}
