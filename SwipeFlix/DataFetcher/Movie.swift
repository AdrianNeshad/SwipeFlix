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
    let release_date: String?
    let vote_average: Double?
    let genre_ids: [Int]

    var posterURL: URL? {
        guard let path = poster_path else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    var releaseYear: String? {
        guard let date = release_date, date.count >= 4 else { return nil }
        return String(date.prefix(4))
    }

    var voteAverage: Double? {
        return vote_average
    }

    var genreNames: [String] {
        let allGenres: [Int: String] = [
            28: "Action", 12: "Adventure", 16: "Animation", 35: "Comedy",
            80: "Crime", 99: "Documentary", 18: "Drama", 10751: "Family",
            14: "Fantasy", 36: "History", 27: "Horror", 10402: "Music",
            9648: "Mystery", 10749: "Romance", 878: "Sci-Fi", 10770: "TV Movie",
            53: "Thriller", 10752: "War", 37: "Western"
        ]
        return genre_ids.compactMap { allGenres[$0] }
    }
}

struct MovieResponse: Codable {
    let results: [Movie]
}
