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
    @IBOutlet var buttonBottomConstraint: NSLayoutConstraint!
    @IBOutlet var bottomBar: UIView!

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }

    @IBAction func cancel(_ sender: UIButton) {
        textField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    func search(forTerm term: String) {
        if term != lastSearchedTerm {
            results = []
        }

        loading = true
        api.search(forTerm: term, page: page) { games in
            self.loading = false
            self.textField.resignFirstResponder()
            guard games.count > 0 else {
                if self.results.count == 0 {
                    let alert = UIAlertController(title: "No Results", message: "Uh-Oh", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }

            let popBar = self.lastSearchedTerm != term
            self.lastSearchedTerm = term
            self.results.append(contentsOf: games)
            self.collectionView.reloadData()
            if popBar {
                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            }
            self.loadingMore = false
        }
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
        let closing = rect.origin.y == collectionView.frame.size.height
        buttonBottomConstraint.constant = closing ? ActionButton.spacing : rect.size.height + ActionButton.spacing
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: { 
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

        let alert = UIAlertController(title: "Which Platform?", message: nil, preferredStyle: .actionSheet)
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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! SearchCell
        let game = results[indexPath.item]
        cell.game = game
        return cell
    }

}

extension SearchViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let game = results[indexPath.item]
        getPlatform(for: game)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let triggerOffset = scrollView.contentOffset.y + scrollView.bounds.size.height
        if scrollView.contentSize.height < triggerOffset {
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
