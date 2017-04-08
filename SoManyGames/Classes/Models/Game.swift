//
//  Game.swift
//  SoManyGames
//
//  Created by Luke Charman on 19/03/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import RealmSwift

class Game: Object {

    dynamic var hasFullDetails = false

    dynamic var id: Int64 = 0
    dynamic var name: String = ""
    dynamic var activePlatform: Platform?
    dynamic var completionPercentage: Double = 0

    var platforms = List<Platform>()

    convenience init?(withJSON json: JSONDictionary) {
        self.init()

        guard let id = json["id"] as? Int64,
            let name = json["name"] as? String,
            let platforms = json["platforms"] as? [JSONDictionary] else { return nil }

        self.id = id
        self.name = name

        for platform in platforms {
            guard let platform = Platform(withJSON: platform) else { continue }
            self.platforms.append(platform)
        }
    }

}
