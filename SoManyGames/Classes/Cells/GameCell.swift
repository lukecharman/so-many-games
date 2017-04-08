//
//  GameCell.swift
//  SoManyGames
//
//  Created by Luke Charman on 21/03/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import UIKit

protocol GameCellDelegate: class {
    func game(_ game: Game, didUpdateProgress progress: Double)
}

class GameCell: UICollectionViewCell {

    static let height: CGFloat = 58
    static let swipeMultiplier: CGFloat = 1.7

    @IBOutlet var label: UILabel!
    @IBOutlet var platformLabel: UILabel!
    @IBOutlet var percentageLabel: UILabel!
    @IBOutlet var progressView: NSLayoutConstraint!
    @IBOutlet var progressBar: UIView!

    var longPressRecognizer: UILongPressGestureRecognizer!
    var panRecognizer: UIPanGestureRecognizer!

    weak var delegate: GameCellDelegate?

    let long = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
    let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))

    var game: Game? {
        didSet {
            guard let game = game else { return }
            label.text = game.name
            platformLabel.text = game.activePlatform?.abbreviation ?? "???"
            calculateProgress(from: game.completionPercentage)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
        backgroundColor = .clear
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setUpRecognizers()

        label.layer.shadowOffset = .zero
        label.layer.shadowRadius = 2

        progressBar.isUserInteractionEnabled = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
    }

    func setUpRecognizers() {
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))

        longPressRecognizer.delegate = self
        panRecognizer.delegate = self

        addGestureRecognizer(longPressRecognizer)
        addGestureRecognizer(panRecognizer)
    }

    func calculateProgress(from ratio: Double) {
        let size = bounds.size.width * CGFloat(ratio)
        progressView.constant = size
        progressBar.alpha = CGFloat(ratio)
        percentageLabel.text = String(describing: Int(ratio * 100)) + "%"
        layoutIfNeeded()
    }

    func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        guard let game = game else { return }

        UIView.animate(withDuration: 0.3) { 
            if recognizer.state == .began {
                self.beginLongPress()
                self.layoutIfNeeded()
            } else if recognizer.state == .ended || recognizer.state == .cancelled {
                self.endLongPress()
                self.calculateProgress(from: game.completionPercentage)
                self.layoutIfNeeded()
            }
        }
    }

    override var isSelected: Bool {
        didSet {
            guard isSelected != oldValue else { return }
            updateSelection()
        }
    }

    func updateSelection() {
        guard let game = game else { return }

        UIView.animate(withDuration: 0.3) { 
            self.backgroundColor = self.isSelected ? UIColor(white: 0, alpha: 0.2) : .clear

            if self.isSelected {
                self.progressBar.alpha = 0
            } else {
                self.calculateProgress(from: game.completionPercentage)
            }
        }
    }

    func beginLongPress() {
        label.alpha = 0.8
        label.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        label.layer.shadowOpacity = 0.2

        platformLabel.alpha = 0
        platformLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        percentageLabel.alpha = 0
        percentageLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        progressBar.alpha = 0
        progressView.constant = 0
    }

    func endLongPress() {
        label.alpha = 1
        label.transform = CGAffineTransform(scaleX: 1, y: 1)
        label.layer.shadowOpacity = 0

        platformLabel.alpha = 1
        platformLabel.transform = CGAffineTransform(scaleX: 1, y: 1)

        percentageLabel.alpha = 1
        percentageLabel.transform = CGAffineTransform(scaleX: 1, y: 1)

        progressBar.alpha = 1
    }

    func handlePan(recognizer: UIPanGestureRecognizer) {
        guard let game = game else { return }

        let originalValue = CGFloat(game.completionPercentage) * bounds.size.width
        let t = max((recognizer.translation(in: self).x * GameCell.swipeMultiplier) + originalValue, 0)
        let ratio = min(max(t / bounds.size.width, 0), 1) // Restrict value between 0 and 1.

        if recognizer.state == .changed {
            progressView.constant = t
            progressBar.alpha = ratio
            percentageLabel.text = "\(String(describing: Int(ratio * 100)))%"

            layoutIfNeeded()
        } else if recognizer.state == .ended || recognizer.state == .cancelled {
            let newRatio = Double(ratio)
            Backlog().update(game) { game.completionPercentage = newRatio }
            delegate?.game(game, didUpdateProgress: newRatio)
        }
    }
    
}

extension GameCell: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !(gestureRecognizer is UIPanGestureRecognizer) && !(otherGestureRecognizer is UIPanGestureRecognizer)
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == panRecognizer else { return true }

        let v = panRecognizer.velocity(in: self)
        let h = fabs(v.x) > fabs(v.y)

        return h // Only pan when horizontal.
    }

}
