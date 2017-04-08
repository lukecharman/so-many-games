//
//  KeyboardObservable.swift
//  SoManyGames
//
//  Created by Luke Charman on 30/03/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import UIKit

protocol KeyboardObservable {
    func startKeyboardObserving(observer: KeyboardObservable)
    func stopKeyboardObserving(observer: KeyboardObservable)
    func keyboardWillMove(to rect: CGRect, over duration: TimeInterval)
}

extension KeyboardObservable where Self: UIViewController {

    func startKeyboardObserving(observer: KeyboardObservable) {
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillChangeFrame, object: nil, queue: nil) { note in
            guard let rect = note.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
            guard let duration = note.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
            observer.keyboardWillMove(to: rect, over: duration)
        }
    }

    func stopKeyboardObserving(observer: KeyboardObservable) {
        NotificationCenter.default.removeObserver(observer)
    }

}

class KeyboardObservableUIViewController: UIViewController, KeyboardObservable {

    override func viewDidLoad() {
        super.viewDidLoad()
        startKeyboardObserving(observer: self)
    }

    deinit {
        stopKeyboardObserving(observer: self)
    }

    func keyboardWillMove(to rect: CGRect, over duration: TimeInterval) {
        fatalError("I should be overridden by your UIViewController")
    }
    
}

