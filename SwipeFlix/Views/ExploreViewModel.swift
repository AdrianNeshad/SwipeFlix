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

    func fetchAll() {
        fetchTopRatedMovies()
        fetchTopRatedTVShows()

        for (id, name) in movieGenres {
            fetchMovies(for: id, genreName: name)
        }

        for (id, name) in tvGenres {
            fetchTVShows(for: id, genreName: name)
        }
    }

    private func fetchTopRatedMovies() {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/top_rated?api_key=19deb7cbacfe2238a57278a1a57a43e6") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let response = try? JSONDecoder().decode(MovieResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.topRated = response.results
                }
            }
        }.resume()
    }

    private func fetchMovies(for genreID: Int, genreName: String) {
        guard let url = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=19deb7cbacfe2238a57278a1a57a43e6&with_genres=\(genreID)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let response = try? JSONDecoder().decode(MovieResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.genreMovies[genreName] = response.results
                }
            }
        }.resume()
    }

    private func fetchTopRatedTVShows() {
        guard let url = URL(string: "https://api.themoviedb.org/3/tv/top_rated?api_key=19deb7cbacfe2238a57278a1a57a43e6") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let response = try? JSONDecoder().decode(TVShowResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.topRatedTV = response.results
                }
            }
        }.resume()
    }

    private func fetchTVShows(for genreID: Int, genreName: String) {
        guard let url = URL(string: "https://api.themoviedb.org/3/discover/tv?api_key=19deb7cbacfe2238a57278a1a57a43e6&with_genres=\(genreID)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let response = try? JSONDecoder().decode(TVShowResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.genreTVShows[genreName] = response.results
                }
            }
        }.resume()
    }
}
