//
//  Backlog.swift
//  SoManyGames
//
//  Created by Luke Charman on 18/03/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import Foundation
import RealmSwift

class Backlog {

    static let manager = Backlog()

    enum GameListType: String {
        case active
        case completed
    }

    static let realm = try! Realm()

    var gameList: GameList = Backlog.buildGameList(with: .active)
    var completedGameList: GameList = Backlog.buildGameList(with: .completed)

    var currentGameListType: GameListType = .active

    static func buildGameList(with id: GameListType) -> GameList {
        let predicate = "id == '\(id.rawValue)'"
        if realm.objects(GameList.self).filter(predicate).isEmpty {
            try! realm.write { realm.add(GameList(id: id.rawValue)) }
        }
        guard let gameList = realm.objects(GameList.self).filter("id == '\(id.rawValue)'").first else { fatalError() }
        return gameList
    }

    func list(forType type: GameListType) -> GameList {
        switch type {
        case .active:
            return gameList
        case .completed:
            return completedGameList
        }
    }

    func switchLists() {
        currentGameListType = currentGameListType == .active ? .completed : .active
    }

    var games: [Game] {
        return list(forType: currentGameListType).games().map { $0 }
    }

    func add(_ game: Game) {
        guard !exists(game) else { return }

        try! Backlog.realm.write {
            Backlog.realm.add(game)
            gameList.add(game)
        }
    }

    func remove(_ games: [Game]) {
        try! Backlog.realm.write {
            gameList.remove(games)
            Backlog.realm.delete(games)
        }
    }

    func reorder(_ from: Int, to: Int) {
        try! Backlog.realm.write {
            gameList.move(from, to: to)
        }
    }

    func sort() {
        try! Backlog.realm.write {
            let games = list(forType: currentGameListType).list.sorted(by: { lhs, rhs in lhs.completionPercentage > rhs.completionPercentage })
            list(forType: currentGameListType).list.removeAll()
            list(forType: currentGameListType).list.append(contentsOf: games)
        }
    }

    func move(_ game: Game, from: GameListType, to: GameListType) {
        try! Backlog.realm.write {
            list(forType: from).remove([game])
            list(forType: to).add(game)
        }
    }

    func update(_ game: Game, with changes: () -> ()) {
        try! Backlog.realm.write {
            changes()
        }
    }

    func clearCompleted() {
        try! Backlog.realm.write {
            completedGameList.clear()
        }
    }

    private func exists(_ game: Game) -> Bool {
        let games = Backlog.realm.objects(Game.self).filter("id == \(game.id)")
        return games.count > 0
    }

}
