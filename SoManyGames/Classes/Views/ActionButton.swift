//
//  ActionButton.swift
//  SoManyGames
//
//  Created by Luke Charman on 30/03/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import UIKit

class ActionButton: UIButton {

    enum ActionButtonAnchor {
        case topLeft, topCenter, topRight
        case bottomLeft, bottomCenter, bottomRight
    }

    static let spacing: CGFloat = 16
    static let side: CGFloat = iPad ? 60 : 44

    convenience init(title: String) {
        self.init()
        setTitle(title, for: .normal)
    }

    func anchor(to view: UIView, at anchor: ActionButtonAnchor) {
        translatesAutoresizingMaskIntoConstraints = false

        widthAnchor.constraint(equalToConstant: ActionButton.side * 2).isActive = true
        heightAnchor.constraint(equalToConstant: ActionButton.side).isActive = true

        switch anchor {
        case .topLeft, .topCenter, .topRight:
            topAnchor.constraint(equalTo: view.topAnchor, constant: ActionButton.spacing).isActive = true
        case .bottomLeft, .bottomCenter, .bottomRight:
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -ActionButton.spacing).isActive = true
        }

        switch anchor {
        case .topLeft, .bottomLeft:
            leftAnchor.constraint(equalTo: view.leftAnchor, constant: ActionButton.spacing).isActive = true
        case .topCenter, .bottomCenter:
            centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        case .topRight, .bottomRight:
            rightAnchor.constraint(equalTo: view.rightAnchor, constant: -ActionButton.spacing).isActive = true
        }
    }

    override func draw(_ rect: CGRect) {
        setTitleColor(Colors.darkest, for: .normal)
        setBackgroundImage(UIImage(named: "Button"), for: .normal)

        titleLabel?.font = UIFont(name: "RPGSystem", size: Sizes.button)

        layer.shadowColor = Colors.darkest.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.5

        super.draw(rect)
    }

}
