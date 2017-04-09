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
    static let side: CGFloat = 52

    convenience init(title: String) {
        self.init()
        setTitle(title, for: .normal)
    }

    func anchor(to view: UIView, at anchor: ActionButtonAnchor) {
        translatesAutoresizingMaskIntoConstraints = false

        widthAnchor.constraint(equalToConstant: ActionButton.side * 2).isActive = true
        heightAnchor.constraint(equalToConstant: ActionButton.side).isActive = true

        switch anchor {
        case .topLeft:
            topAnchor.constraint(equalTo: view.topAnchor, constant: ActionButton.spacing).isActive = true
            leftAnchor.constraint(equalTo: view.leftAnchor, constant: ActionButton.spacing).isActive = true
        case .topCenter:
            topAnchor.constraint(equalTo: view.topAnchor, constant: ActionButton.spacing).isActive = true
            centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        case .topRight:
            topAnchor.constraint(equalTo: view.topAnchor, constant: ActionButton.spacing).isActive = true
            rightAnchor.constraint(equalTo: view.rightAnchor, constant: -ActionButton.spacing).isActive = true
        case .bottomLeft:
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -ActionButton.spacing).isActive = true
            leftAnchor.constraint(equalTo: view.leftAnchor, constant: ActionButton.spacing).isActive = true
        case .bottomCenter:
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -ActionButton.spacing).isActive = true
            centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        case .bottomRight:
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -ActionButton.spacing).isActive = true
            rightAnchor.constraint(equalTo: view.rightAnchor, constant: -ActionButton.spacing).isActive = true
        }
    }

    override func draw(_ rect: CGRect) {
        setTitleColor(UIColor(red:0.06, green:0.22, blue:0.06, alpha:1.0), for: .normal)
        setBackgroundImage(UIImage(named: "Button"), for: .normal)

        titleLabel?.font = UIFont(name: "RPGSystem", size: 60)

        layer.masksToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.6

        addMotion()

        super.draw(rect)
    }

}
