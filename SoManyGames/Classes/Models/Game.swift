//
//  Game.swift
//  SoManyGames
//
//  Created by Luke Charman on 19/03/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import RealmSwift

@objc public class Game: Object {

    @objc dynamic var hasFullDetails = false

    @objc dynamic var id: Int64 = 0
    @objc dynamic var name: String = ""
    @objc dynamic var activePlatform: Platform?
    @objc dynamic var completionPercentage: Double = 0

    var platforms = List<Platform>()

    convenience init?(withJSON json: JSONDictionary) {
        self.init()

        guard let id = json["id"] as? Int64,
            let name = json["name"] as? String else { return nil }

        self.id = id
        self.name = name

        guard let platforms = json["platforms"] as? [JSONDictionary] else { return }

        for platform in platforms {
            guard let platform = Platform(withJSON: platform) else { continue }
            self.platforms.append(platform)
        }
    }

    static func ==(lhs: Game, rhs: Game) -> Bool {
        return lhs.id == rhs.id
    }

    override public var hashValue: Int {
        return id.hashValue
    }

}
