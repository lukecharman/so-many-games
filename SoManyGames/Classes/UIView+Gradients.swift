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
        let horizontalLayer = CAGradientLayer()
        horizontalLayer.frame = rotationSafeFrame()
        horizontalLayer.colors = [UIColor.black.withAlphaComponent(0.1).cgColor, UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.25).cgColor]
        horizontalLayer.startPoint = CGPoint(x: 0, y: 0)
        horizontalLayer.endPoint = CGPoint(x: 1, y: 0)
        horizontalLayer.anchorPoint = center
        layer.addSublayer(horizontalLayer)

        let verticalLayer = CAGradientLayer()
        verticalLayer.frame = rotationSafeFrame()
        verticalLayer.colors = [UIColor.black.withAlphaComponent(0.2).cgColor, UIColor.clear.cgColor]
        verticalLayer.startPoint = CGPoint(x: 0, y: 0)
        verticalLayer.endPoint = CGPoint(x: 0, y: 1)
        verticalLayer.anchorPoint = center
        layer.addSublayer(verticalLayer)
    }

    private func rotationSafeFrame() -> CGRect {
        let x: CGFloat = -1000
        let y: CGFloat = -1000
        let w = frame.size.width + 2000
        let h = frame.size.height + 2000

        return CGRect(x: x, y: y, width: w, height: h)
    }

}
