//
//  GameViewController.swift
//  SoManyGames
//
//  Created by Luke Charman on 11/08/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    var game: Game?
    var doneButton = ActionButton(title: "done")

    let api: APIClient = GiantBomb()

    @IBOutlet weak var gradientView: GradientView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        makeDoneButton()

        guard let game = game else { return }
        api.similarGames(to: [game]) { $0.forEach { print($0.name) } }
    }

    func makeDoneButton() {
        view.addSubview(doneButton)

        doneButton.anchor(to: view, at: .bottomRight)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: UIControl.Event.touchUpInside)
    }

    @objc func doneButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.gradientView.resize()
        }, completion: nil)
    }

}
