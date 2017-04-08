//
//  UIView+MotionHelper.swift
//  SoManyGames
//
//  Created by Luke Charman on 01/04/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import UIKit

extension UIView {

    func addMotion() {
        let h = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        let v = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)

        h.minimumRelativeValue = -10
        h.maximumRelativeValue = 10
        v.minimumRelativeValue = -10
        v.maximumRelativeValue = 10

        addMotionEffect(h)
        addMotionEffect(v)
    }

}
