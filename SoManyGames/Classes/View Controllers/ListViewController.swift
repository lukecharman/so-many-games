//
//  ListViewController.swift
//  SoManyGames
//
//  Created by Luke Charman on 18/03/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import UIKit

class ListViewController: UICollectionViewController {

    @IBOutlet var gradientView: GradientView!

    var games: [Game] = Backlog.manager.games {
        didSet {
            updateEmptyStateLabel()
        }
    }

    var button = ActionButton(title: "add")
    var sortButton = ActionButton(title: "sort")
    var listButton = ActionButton(title: "playing")

    var selectedGames = [Game]()
    var programmaticDeselection = false
    var emptyStateLabel = UILabel()

}

// MARK: Setup

extension ListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.allowsMultipleSelection = true
        collectionView?.backgroundColor = .clear

        button.titleLabel?.font = UIFont(name: "RPGSystem", size: Sizes.button)

        makeAddButton()
        makeSortButton()
        makeListButton()
        makeEmptyStateLabel()
        updateEmptyStateLabel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        games = Backlog.manager.games
        collectionView?.reloadData()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        collectionView?.collectionViewLayout.invalidateLayout()
        for cell in collectionView!.visibleCells {
            guard let cell = cell as? GameCell else { continue }
            cell.calculateProgressOnRotation()
        }

        coordinator.animate(alongsideTransition: { _ in
            self.gradientView.resize()
        }, completion: nil)
    }

}

// MARK: Button

extension ListViewController {

    func makeAddButton() {
        guard let collectionView = collectionView else { return }
        guard let superview = collectionView.superview else { return }

        superview.addSubview(button)

        button.anchor(to: collectionView, at: .bottomLeft)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    func makeSortButton() {
        guard let collectionView = collectionView else { return }
        guard let superview = collectionView.superview else { return }

        superview.addSubview(sortButton)

        sortButton.anchor(to: collectionView, at: .bottomRight)
        sortButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
    }

    func makeListButton() {
        guard let collectionView = collectionView else { return }
        guard let superview = collectionView.superview else { return }

        superview.addSubview(listButton)

        listButton.anchor(to: collectionView, at: .bottomCenter)
        listButton.addTarget(self, action: #selector(listButtonTapped), for: .touchUpInside)
    }

    func buttonTapped() {
        guard Backlog.manager.currentGameListType == .active else { return }

        if button.title(for: .normal) == "add" {
            performSegue(withIdentifier: "AddGame", sender: nil)
        } else {
            delete()
        }
    }

    func sortButtonTapped() {
        guard Backlog.manager.currentGameListType == .active else { return }

        Backlog.manager.sort()
        collectionView?.performBatchUpdates({
            self.animateReorder()
        }, completion: { _ in
            self.games = Backlog.manager.games
            self.collectionView?.reloadData()
        })
    }

    func listButtonTapped() {
        Backlog.manager.switchLists()
        games = Backlog.manager.games
        collectionView?.reloadData()

        let active = Backlog.manager.currentGameListType == .active
        let title = active ? "playing" : "finished"
        listButton.setTitle(title, for: .normal)
        button.isHidden = !active
    }

    func animateReorder() {
        let old = self.games
        let new = Backlog.manager.games

        for index in 0..<old.count {
            let fromIndexPath = IndexPath(item: index, section: 0)
            let toIndexPath = IndexPath(item: new.index(of: old[index])!, section: 0)
            collectionView?.moveItem(at: fromIndexPath, to: toIndexPath)
        }
    }

    func updateButton() {
        if selectedGames.count > 0 {
            button.setTitle("delete", for: .normal)
        } else {
            button.setTitle("add", for: .normal)
        }
    }

    func makeEmptyStateLabel() {
        guard let collectionView = collectionView else { return }
        guard let superview = collectionView.superview else { return }

        superview.addSubview(button)

        emptyStateLabel = UILabel()
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.font = UIFont(name: "RPGSystem", size: Sizes.emptyState)
        emptyStateLabel.textColor = Colors.darkest

        superview.addSubview(emptyStateLabel)

        emptyStateLabel.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
        emptyStateLabel.centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: -41).isActive = true
        emptyStateLabel.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: 0.9).isActive = true
    }

    func updateEmptyStateLabel() {
        emptyStateLabel.isHidden = games.count > 0

        let active = Backlog.manager.currentGameListType == .active
        if active {
            emptyStateLabel.text = "Looks like your backlog is empty. Lucky you!\n\nIf you have games to add, tap the add button."
            sortButton.isHidden = !emptyStateLabel.isHidden
        }   else {
            emptyStateLabel.text = "Looks like your completed games list is empty.\n\nWhen you mark a game as 100% complete, it'll show up here."
            sortButton.isHidden = true
            return
        }
    }

}

// MARK:- Deletion

extension ListViewController {

    func delete() {
        let singular = "Would you like to delete this game?"
        let plural = "Would you like to delete these games?"
        let string = self.selectedGames.count > 1 ? plural : singular
        let alert = UIAlertController(title: "Delete?", message: string, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in self.confirmDelete() }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in self.cancelDelete() }))
        present(alert, animated: true, completion: nil)
    }

    func markAsCompleted(game: Game) {
        Backlog.manager.move(game, from: .active, to: .completed)
        games = Backlog.manager.games
        collectionView?.reloadData()
    }

    func markAsUncompleted(game: Game) {
        Backlog.manager.move(game, from: .completed, to: .active)
        games = Backlog.manager.games
        collectionView?.reloadData()
    }

    func confirmDelete() {
        guard let cv = collectionView, let indexPaths = collectionView!.indexPathsForSelectedItems else {
            fatalError("You're trying to delete items that don't exist.")
        }

        indexPaths.forEach { collectionView?.deselectItem(at: $0, animated: false) }

        cv.performBatchUpdates({
            cv.deleteItems(at: indexPaths)
            Backlog.manager.remove(self.selectedGames)
            self.games = Backlog.manager.games
            self.selectedGames = []
        }, completion: { success in
            cv.reloadData()
            self.updateButton()
        })
    }

    func cancelDelete() {
        selectedGames = []
        collectionView?.visibleCells.forEach {
            programmaticDeselection = true
            collectionView?.deselectItem(at: collectionView!.indexPath(for: $0)!, animated: false)
            collectionView(collectionView!, didDeselectItemAt: collectionView!.indexPath(for: $0)!)
            programmaticDeselection = false
        }
        updateButton()
    }
}

// MARK:- Selection

extension ListViewController {

    func select(cell: GameCell, at indexPath: IndexPath) {
        selectedGames.append(games[indexPath.item])
        updateButton()
    }

    func deselect(cell: GameCell, at indexPath: IndexPath) {
        if !programmaticDeselection {
            guard let index = selectedGames.index(of: games[indexPath.item]) else { return }
            selectedGames.remove(at: index)
        }

        updateButton()
    }

}

// MARK: UICollectionViewDataSource

extension ListViewController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return games.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCell", for: indexPath) as? GameCell else {
            fatalError("Could not dequeue a reusable GameCell.")
        }

        cell.game = games[indexPath.item]
        cell.delegate = self
        
        return cell
    }

}

// MARK: UICollectionViewDelegateFlowLayout

extension ListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if traitCollection.horizontalSizeClass == .regular {
            return CGSize(width: collectionView.bounds.size.width / 2, height: GameCell.height)
        } else {
            return CGSize(width: collectionView.bounds.size.width, height: GameCell.height)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }

}

// MARK: UICollectionViewDelegate

extension ListViewController {

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? GameCell else { return }
        select(cell: cell, at: indexPath)
    }

    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? GameCell else { return }
        deselect(cell: cell, at: indexPath)
    }

    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath != destinationIndexPath else { return }

        let swap = games[sourceIndexPath.item]
        games[sourceIndexPath.item] = games[destinationIndexPath.item]
        games[destinationIndexPath.item] = swap

        Backlog.manager.reorder(sourceIndexPath.item, to: destinationIndexPath.item)
    }

}

// MARK: GameCellDelegate

extension ListViewController: GameCellDelegate {

    func game(_ game: Game, didUpdateProgress progress: Double) {
        if progress >= 1 && Backlog.manager.currentGameListType == .active {
            askToDelete(game: game)
        } else if progress < 1 && Backlog.manager.currentGameListType == .completed {
            askToMoveBack(game: game)
        }
    }

    func askToDelete(game: Game) {
        guard Backlog.manager.currentGameListType == .active else { return }
        let alert = UIAlertController(title: "You're done?", message: "Want to move this game to your complete list?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in self.markAsCompleted(game: game) }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        show(alert, sender: nil)
    }

    func askToMoveBack(game: Game) {
        guard Backlog.manager.currentGameListType == .completed else { return }
        let alert = UIAlertController(title: "Back into it?", message: "Want to move this game back to your active list?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in self.markAsUncompleted(game: game) }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        show(alert, sender: nil)
    }

}
