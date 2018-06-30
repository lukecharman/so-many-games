//
//  GiantBomb.swift
//  SoManyGames
//
//  Created by Luke Charman on 18/03/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import Foundation

public struct GiantBomb: APIClient {

    public typealias Counts = [Int64: Int]

    private let session: URLSession = .shared

    public func search(for term: String, page: Int = 1, completion: SearchCompletion?) {
        guard let url = URLBuilder().search(for: term, at: page) else {
            fatalError("Could not build search URL")
        }

        session.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async { self.handleSearchResult(withData: data, completion: completion) }
        }.resume()
    }

    private func handleSearchResult(withData data: Data?, completion: SearchCompletion?) {
        guard let data = data,
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let dict = json as? JSONDictionary,
            let results = dict["results"] as? [[String: AnyObject]] else {
                completion?([])
                return
        }

        completion?(results.compactMap { Game(withJSON: $0) })
    }

}

public extension GiantBomb {

    public func similarGames(to games: [Game], completion: SearchCompletion?) {
        guard !games.isEmpty else {
            fatalError("Can't get details for an empty game list!")
        }

        let queue = DispatchQueue(label: "com.lukecharman.somanygames", attributes: .concurrent, target: .main)
        let group = DispatchGroup()

        let urls = games.compactMap { URLBuilder().details(for: $0) }

        var similarGames = [Game]()

        urls.forEach { url in
            group.enter()
            queue.async(group: group) {
                self.fetchSimilarGames(from: url, completion: { games in
                    similarGames.append(contentsOf: games)
                    group.leave()
                })
            }
        }

        group.notify(queue: DispatchQueue.main) {
            completion?(self.sort(similarGames))
        }
    }

    private func sort(_ games: [Game]) -> [Game] {
        var counts = Counts()

        games.forEach { counts[$0.id] = (counts[$0.id] ?? 0) + 1 }

        let sorted = dedupe(games: games, with: counts).sorted(by: {
            guard let first = counts[$0.id], let second = counts[$1.id] else { return true }
            return first > second
        })

        return sorted
    }

    private func dedupe(games: [Game], with counts: Counts) -> [Game] {
        var copy = games

        let elementsWithDuplicates = counts.filter { (id, count) in count > 1 }
        
        for element in elementsWithDuplicates {
            guard element.value > 1 else { continue }
            if let duplicateToRemove = game(with: element.key, in: copy) {
                if let indexOfDuplicateToRemove = copy.index(of: duplicateToRemove) {
                    copy.remove(at: indexOfDuplicateToRemove)
                }
            }
        }

        return copy
    }

    private func game(with id: Int64, in array: [Game]) -> Game? {
        for game in array {
            if game.id == id {
                return game
            }
        }

        return nil
    }

    private func fetchSimilarGames(from url: URL, completion: @escaping SearchCompletion) {
        session.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async { self.handleGameResult(withData: data, completion: completion) }
        }.resume()
    }

    private func handleGameResult(withData data: Data?, completion: SearchCompletion?) {
        guard let data = data,
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let dict = json as? JSONDictionary,
            let results = dict["results"] as? [String: AnyObject],
            let similarGames = results["similar_games"] as? [[String: AnyObject]] else {
                completion?([])
                return
        }

        completion?(similarGames.compactMap { Game(withJSON: $0) })
    }

}
