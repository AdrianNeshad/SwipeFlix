//
//  Movie.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-05-31.
//

import Foundation

struct Movie: Identifiable, Codable {
    let id: Int
    let title: String
    let overview: String
    let poster_path: String?

    var posterURL: URL? {
        guard let path = poster_path else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
}

struct MovieResponse: Codable {
    let results: [Movie]
}
