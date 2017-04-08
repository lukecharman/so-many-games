//
//  SearchCell.swift
//  SoManyGames
//
//  Created by Luke Charman on 21/03/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import UIKit

class SearchCell: UICollectionViewCell {

    @IBOutlet var label: UILabel!

    var game: Game? {
        didSet {
            label.text = game?.name
        }
    }
    
}

