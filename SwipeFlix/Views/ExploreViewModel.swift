//
//  ExploreViewModel.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-02.
//

import SwiftUI

class ExploreViewModel: ObservableObject {
    @Published var topRated: [Movie] = []
    @Published var genreMovies: [String: [Movie]] = [:]

    @Published var topRatedTV: [TVShow] = []
    @Published var genreTVShows: [String: [TVShow]] = [:]

    private let movieGenres: [Int: String] = [
        28: "Action", 12: "Adventure", 16: "Animation", 35: "Comedy",
        80: "Crime", 99: "Documentary", 18: "Drama", 10751: "Family",
        14: "Fantasy", 27: "Horror", 9648: "Mystery", 10749: "Romance",
        878: "Sci-Fi", 53: "Thriller"
    ]

    private let tvGenres: [Int: String] = [
        10759: "Action & Adventure", 16: "Animation", 35: "Comedy",
        80: "Crime", 99: "Documentary", 18: "Drama", 10751: "Family",
        10762: "Kids", 9648: "Mystery", 10763: "News", 10764: "Reality",
        10765: "Sci-Fi & Fantasy", 10766: "Soap", 10767: "Talk",
        10768: "War & Politics", 37: "Western"
    ]

    private var hasFetchedMovies = false
    private var hasFetchedTV = false

    func fetchAll() {
        if !hasFetchedMovies {
            fetchTopRatedMovies()
            for (id, name) in movieGenres {
                fetchMovies(for: id, genreName: name)
            }
            hasFetchedMovies = true
        }

        if !hasFetchedTV {
            fetchTopRatedTVShows()
            for (id, name) in tvGenres {
                fetchTVShows(for: id, genreName: name)
            }
            hasFetchedTV = true
        }
    }
    
    private func fetchTopRatedMovies() {
        let pageRange = 1...3
        var allResults: [Movie] = []
        let group = DispatchGroup()

        for page in pageRange {
            guard let url = URL(string: "https://api.themoviedb.org/3/movie/top_rated?api_key=19deb7cbacfe2238a57278a1a57a43e6&page=\(page)") else { continue }

            group.enter()
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data,
                   let response = try? JSONDecoder().decode(MovieResponse.self, from: data) {
                    DispatchQueue.main.async {
                        allResults.append(contentsOf: response.results)
                    }
                }
                group.leave()
            }.resume()
        }

        group.notify(queue: .main) {
            self.topRated = allResults
        }
    }

    private func fetchMovies(for genreID: Int, genreName: String) {
        let pageRange = 1...3
        var allResults: [Movie] = []
        let group = DispatchGroup()

        for page in pageRange {
            guard let url = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=19deb7cbacfe2238a57278a1a57a43e6&with_genres=\(genreID)&page=\(page)") else { continue }

            group.enter()
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data,
                   let response = try? JSONDecoder().decode(MovieResponse.self, from: data) {
                    DispatchQueue.main.async {
                        allResults.append(contentsOf: response.results)
                    }
                }
                group.leave()
            }.resume()
        }

        group.notify(queue: .main) {
            if self.genreMovies[genreName] == nil {
                self.genreMovies[genreName] = allResults.shuffled()
            }
        }
    }
    
    private func fetchTopRatedTVShows() {
        let pageRange = 1...3
        var allResults: [TVShow] = []
        let group = DispatchGroup()

        for page in pageRange {
            guard let url = URL(string: "https://api.themoviedb.org/3/tv/top_rated?api_key=19deb7cbacfe2238a57278a1a57a43e6&page=\(page)") else { continue }

            group.enter()
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data,
                   let response = try? JSONDecoder().decode(TVShowResponse.self, from: data) {
                    DispatchQueue.main.async {
                        allResults.append(contentsOf: response.results)
                    }
                }
                group.leave()
            }.resume()
        }

        group.notify(queue: .main) {
            self.topRatedTV = allResults
        }
    }

    private func fetchTVShows(for genreID: Int, genreName: String) {
        let pageRange = 1...3
        var allResults: [TVShow] = []
        let group = DispatchGroup()

        for page in pageRange {
            guard let url = URL(string: "https://api.themoviedb.org/3/discover/tv?api_key=19deb7cbacfe2238a57278a1a57a43e6&with_genres=\(genreID)&page=\(page)") else { continue }

            group.enter()
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data,
                   let response = try? JSONDecoder().decode(TVShowResponse.self, from: data) {
                    DispatchQueue.main.async {
                        allResults.append(contentsOf: response.results)
                    }
                }
                group.leave()
            }.resume()
        }

        group.notify(queue: .main) {
            if self.genreTVShows[genreName] == nil {
                self.genreTVShows[genreName] = allResults.shuffled()
            }
        }
    }
}
