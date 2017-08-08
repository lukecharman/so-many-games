//
//  GiantBomb.swift
//  SoManyGames
//
//  Created by Luke Charman on 18/03/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import Foundation

struct GiantBomb: APIClient {

    let session: URLSession = .shared

    func search(for term: String, page: Int = 1, completion: SearchCompletion?) {
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

        completion?(results.flatMap { Game(withJSON: $0) })
    }

}

extension GiantBomb {

    func similarGames(to games: [Game], completion: SearchCompletion?) {
        guard !games.isEmpty else {
            fatalError("Can't get details for an empty game list!")
        }

        let queue = DispatchQueue(label: "com.lukecharman.somanygames", attributes: .concurrent, target: .main)
        let group = DispatchGroup()

        let urls = games.flatMap { URLBuilder().details(for: $0) }

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
        return games.sorted(by: { $0.name < $1.name })
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

        completion?(similarGames.flatMap { Game(withJSON: $0) })
    }

}
