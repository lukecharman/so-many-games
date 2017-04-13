//
//  Theme.swift
//  SoManyGames
//
//  Created by Luke Charman on 12/04/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import UIKit

let iPad = UIDevice.current.userInterfaceIdiom == .pad

struct Colors {
    static let lightest = UIColor(red:0.61, green:0.74, blue:0.06, alpha:1.0)
    static let light = UIColor(red:0.55, green:0.67, blue:0.06, alpha:1.0)
    static let dark = UIColor(red:0.19, green:0.38, blue:0.19, alpha:1.0)
    static let darkest = UIColor(red:0.06, green:0.22, blue:0.06, alpha:1.0)
}

struct Sizes {
    static let button: CGFloat = iPad ? 34 : 20
    static let emptyState: CGFloat = iPad ? 50 : 30
    static let gameCellMain: CGFloat = iPad ? 32 : 28
    static let gameCellSub: CGFloat = iPad ? 28 : 20
}
