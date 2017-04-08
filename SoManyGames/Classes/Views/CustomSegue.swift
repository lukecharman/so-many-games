//
//  CustomSegue.swift
//  SoManyGames
//
//  Created by Luke Charman on 30/03/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import UIKit

class CustomSegue: UIStoryboardSegue {

    override func perform() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade

        source.view.layer.add(transition, forKey: kCATransition)
        source.present(destination, animated: false, completion: nil)
    }

}
