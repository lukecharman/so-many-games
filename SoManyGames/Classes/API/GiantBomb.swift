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

    func search(forTerm term: String, page: Int = 1, completion: SearchCompletion?) {
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

    struct URLBuilder {

        func search(for term: String, at page: Int) -> URL? {
            guard let formattedTerm = term.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else { return nil }
            return URL(string: "https://www.giantbomb.com/api/search?query=" + formattedTerm + "&resources=game&page=" + "\(page)" + "&format=json&api_key=032cf98d2e30c7f3fe851d68798a9256a6df0766")
        }
        
    }

}
