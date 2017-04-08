//
//  Backlog.swift
//  SoManyGames
//
//  Created by Luke Charman on 18/03/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import Foundation
import RealmSwift

struct Backlog {

    let realm = try! Realm()

    var gameList: GameList {
        if realm.objects(GameList.self).isEmpty {
            try! realm.write { realm.add(GameList()) }
        }
        guard let gameList = realm.objects(GameList.self).first else { fatalError() }
        return gameList
    }

    var games: [Game] {
        return gameList.games().map { $0 }
    }

    func add(_ game: Game) {
        guard !exists(game) else { return }

        try! realm.write {
            realm.add(game)
            gameList.add(game)
        }
    }

    func remove(_ games: [Game]) {
        try! realm.write {
            gameList.remove(games)
            realm.delete(games)
        }
    }

    func move(_ from: Int, to: Int) {
        try! realm.write {
            gameList.move(from, to: to)
        }
    }

    func update(_ game: Game, with changes: () -> ()) {
        try! realm.write {
            changes()
        }
    }

    private func exists(_ game: Game) -> Bool {
        let games = realm.objects(Game.self).filter("id == \(game.id)")
        return games.count > 0
    }

}
