//
//  GameList.swift
//  SoManyGames
//
//  Created by Luke Charman on 25/03/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import RealmSwift

class GameList: Object {

    var list = List<Game>()

    func games() -> [Game] {
        return list.map { $0 }
    }

    func add(_ game: Game) {
        list.append(game)
    }

    func remove(_ games: [Game]) {
        games.forEach {
            guard let index = list.index(of: $0) else { return }
            list.remove(at: index)
        }
    }

    func move(_ from: Int, to: Int) {
        list.move(from: from, to: to)
    }
    
}
