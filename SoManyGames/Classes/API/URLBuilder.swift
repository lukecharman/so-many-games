//
//  URLBuilder.swift
//  SoManyGames
//
//  Created by Luke Charman on 08/08/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import Foundation

struct URLBuilder {

    func search(for term: String, at page: Int) -> URL? {
        guard let formattedTerm = term.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else { return nil }
        return URL(string: "https://www.giantbomb.com/api/search?query=" + formattedTerm + "&resources=game&page=" + "\(page)" + "&format=json&api_key=032cf98d2e30c7f3fe851d68798a9256a6df0766")
    }

    func details(for game: Game) -> URL? {
        return URL(string: "https://www.giantbomb.com/api/game/" + String(game.id) + "?format=json&api_key=032cf98d2e30c7f3fe851d68798a9256a6df0766")
    }

}
