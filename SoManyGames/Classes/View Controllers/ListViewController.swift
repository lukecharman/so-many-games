//
//  ListViewController.swift
//  SoManyGames
//
//  Created by Luke Charman on 18/03/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import UIKit

class ListViewController: UICollectionViewController {

    var games: [Game] = Backlog().games
    var button = ActionButton(title: "+")
    var sortButton = ActionButton(title: "s")

    var selectedGames = [Game]()
    var programmaticDeselection = false

}

// MARK: Setup

extension ListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.superview?.makeGradients()
        collectionView?.allowsMultipleSelection = true
        collectionView?.backgroundColor = .clear

        button.titleLabel?.font = UIFont(name: "RPGSystem", size: 70)

        makeAddButton()
        makeSortButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        games = Backlog().games
        collectionView?.reloadData()
    }

}

// MARK: Button

extension ListViewController {

    func makeAddButton() {
        guard let collectionView = collectionView else { return }
        guard let superview = collectionView.superview else { return }

        superview.addSubview(button)

        button.anchor(to: collectionView, at: .bottom)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    func makeSortButton() {
        guard let collectionView = collectionView else { return }
        guard let superview = collectionView.superview else { return }

        superview.addSubview(sortButton)

        sortButton.anchor(to: collectionView, at: .top)
        sortButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
    }

    func buttonTapped() {
        if button.title(for: .normal) == "+" {
            performSegue(withIdentifier: "AddGame", sender: nil)
        } else {
            delete()
        }
    }

    func sortButtonTapped() {
        Backlog().sort()
        collectionView?.performBatchUpdates({
            self.animateReorder()
        }, completion: { _ in
            self.games = Backlog().games
            self.collectionView?.reloadData()
        })
    }

    func animateReorder() {
        let old = self.games
        let new = Backlog().games

        for index in 0..<old.count {
            let fromIndexPath = IndexPath(item: index, section: 0)
            let toIndexPath = IndexPath(item: new.index(of: old[index])!, section: 0)
            collectionView?.moveItem(at: fromIndexPath, to: toIndexPath)
        }
    }

    func updateButton() {
        if selectedGames.count > 0 {
            button.setTitle("X", for: .normal)
            button.titleLabel?.font = UIFont(name: "RPGSystem", size: 60)
        } else {
            button.setTitle("+", for: .normal)
            button.titleLabel?.font = UIFont(name: "RPGSystem", size: 70)
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
        Backlog().move(game, from: .active, to: .completed)
        games = Backlog().games
        collectionView?.reloadData()
        print("Active: \(Backlog().gameList.games().count)")
        print("Completed: \(Backlog().completedGameList.games().count)")
    }

    func confirmDelete() {
        guard let cv = collectionView, let indexPaths = collectionView!.indexPathsForSelectedItems else {
            fatalError("You're trying to delete items that don't exist.")
        }

        indexPaths.forEach { collectionView?.deselectItem(at: $0, animated: false) }

        cv.performBatchUpdates({
            cv.deleteItems(at: indexPaths)
            Backlog().remove(self.selectedGames)
            self.games = Backlog().games
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
        return CGSize(width: collectionView.bounds.size.width, height: GameCell.height)
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

        Backlog().reorder(sourceIndexPath.item, to: destinationIndexPath.item)
    }

}

// MARK: GameCellDelegate

extension ListViewController: GameCellDelegate {

    func game(_ game: Game, didUpdateProgress progress: Double) {
        if progress >= 1 {
            askToDelete(game: game)
        }
    }

    func askToDelete(game: Game) {
        let alert = UIAlertController(title: "You're done?", message: "Want to move this game to your complete list?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in self.markAsCompleted(game: game) }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        show(alert, sender: nil)
    }

}
