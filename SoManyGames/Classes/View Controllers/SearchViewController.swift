//
//  SearchViewController.swift
//  SoManyGames
//
//  Created by Luke Charman on 18/03/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import UIKit

class SearchViewController: KeyboardObservableUIViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var textField: UITextField!
    @IBOutlet var cancelButton: ActionButton!
    @IBOutlet var bottomBar: UIView!

    @IBOutlet var bottomBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet var buttonHeightConstraint: NSLayoutConstraint!
    @IBOutlet var bottomBarBottomConstraint: NSLayoutConstraint!

    @IBOutlet var gradientView: GradientView!

    let api = GiantBomb()

    var page = 1
    var lastSearchedTerm: String = ""

    var results: [Game] = [] {
        didSet { collectionView.reloadData() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 84, right: 0)
        view.backgroundColor = .clear

        view.bringSubview(toFront: bottomBar)
        view.bringSubview(toFront: cancelButton)
        view.bringSubview(toFront: textField)

        bottomBarHeightConstraint.constant = iPad ? 92 : 76
        buttonHeightConstraint.constant = 44
        view.setNeedsLayout()

        textField.font = textField.font?.withSize(Sizes.emptyState)
        textField.becomeFirstResponder()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.gradientView.resize()
        }, completion: nil)
    }

    @IBAction func cancel(_ sender: UIButton) {
        textField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    func search(forTerm term: String) {
        textField.resignFirstResponder()

        if term != lastSearchedTerm {
            results.removeAll()
        }

        loading = true

        api.search(for: term, page: page) { [weak self] games in
            guard let strongSelf = self else { return }

            strongSelf.loading = false
            strongSelf.loadingMore = false
            strongSelf.lastSearchedTerm = term
            strongSelf.results.append(contentsOf: games)

            if games.count > 0 && self?.results.count == 0 {
                strongSelf.presentNoResultsAlert(for: term)
            } else if games.count == 0 && strongSelf.results.count > 0 {
                strongSelf.presentNoMoreResultsAlert(for: term)
            }

            strongSelf.collectionView.reloadData()
        }
    }

    func presentNoResultsAlert(for term: String) {
        let alert = UIAlertController(title: "No Games Found", message: "We couldn't find any games containing \"\(term)\".", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            self.textField.becomeFirstResponder()
        }))
        present(alert, animated: true, completion: nil)
        textField.text = ""
    }

    func presentNoMoreResultsAlert(for term: String) {
        let alert = UIAlertController(title: "That's All!", message: "We found a total of \(results.count) games containing \"\(term)\".", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    var originalTerm: String?
    var loading = false {
        didSet {
            if loading {
                originalTerm = textField.text
                startLoading()
            } else {
                stopLoading()
            }
        }
    }

    var index = 0

    func startLoading() {
        guard loading else { return }
        textField.isUserInteractionEnabled = false

        let strings = [originalTerm! + ".", originalTerm! + "..", originalTerm! + "..."]

        textField.text = strings[index]
        index += 1
        if index > 2 { index = 0 }

        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.25) { 
            self.startLoading()
        }
    }

    func stopLoading() {
        guard !loading else { return }
        textField.isUserInteractionEnabled = true

        textField.text = originalTerm
        index = 0
    }

    var loadingMore = false

    func loadMore() {
        guard !loadingMore else { return }
        loadingMore = true
        page += 1
        search(forTerm: lastSearchedTerm)
    }

    override func keyboardWillMove(to rect: CGRect, over duration: TimeInterval) {
        let closing = rect.origin.y == collectionView.frame.size.height + 20
        bottomBarBottomConstraint.constant = closing ? 0 : rect.size.height
        UIView.animateKeyframes(withDuration: duration - 0.1, delay: 0, options: .calculationModeCubic, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    func getPlatform(for game: Game) {
        guard game.platforms.count > 1 else {
            game.activePlatform = game.platforms.first!
            Backlog.manager.add(game)
            dismiss(animated: true, completion: nil)
            return
        }

        let style: UIAlertControllerStyle = UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
        let alert = UIAlertController(title: "Which Platform?", message: nil, preferredStyle: style)
        alert.view.tintColor = Colors.dark

        let platformsArray = Array(game.platforms)

        for (i, platform) in platformsArray.enumerated() {
            alert.addAction(UIAlertAction(title: platform.name, style: .default, handler: { action in
                game.activePlatform = platformsArray[i]
                Backlog.manager.add(game)
                self.dismiss(animated: true, completion: nil)
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        show(alert, sender: nil)
    }

}

extension SearchViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return results.count > 0 ? 2 : 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? results.count : 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! SearchCell
            let game = results[indexPath.item]
            cell.game = game
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadMoreCell", for: indexPath) as! LoadMoreCell
            return cell
        }
    }

}

extension SearchViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if indexPath.section == 0 {
            let game = results[indexPath.item]
            getPlatform(for: game)
        } else {
            loadMore()
        }
    }

}

extension SearchViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let term = textField.text, !term.characters.isEmpty else { return false }
        search(forTerm: term)
        return true
    }

}
