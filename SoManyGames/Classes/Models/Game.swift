//
//  Game.swift
//  SoManyGames
//
//  Created by Luke Charman on 19/03/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import RealmSwift

@objc class Game: Object {

    @objc dynamic var hasFullDetails = false

    @objc dynamic var id: Int64 = 0
    @objc dynamic var name: String = ""
    @objc dynamic var activePlatform: Platform?
    @objc dynamic var completionPercentage: Double = 0

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
