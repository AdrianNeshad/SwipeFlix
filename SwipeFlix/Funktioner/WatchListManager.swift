//
//  WatchListManager.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-01.
//

import Foundation

class WatchListManager: ObservableObject {
    @Published var savedMovies: [Movie] = [] {
        didSet { saveMovies() }
    }

    @Published var savedTVShows: [TVShow] = [] {
        didSet { saveTVShows() }
    }

    private let movieKey = "savedMovies"
    private let tvKey = "savedTVShows"

    init() {
        loadMovies()
        loadTVShows()
    }

    func addMovie(_ movie: Movie) {
        if !savedMovies.contains(where: { $0.id == movie.id }) {
            savedMovies.append(movie)
        }
    }

    func addTVShow(_ show: TVShow) {
        if !savedTVShows.contains(where: { $0.id == show.id }) {
            savedTVShows.append(show)
        }
    }

    func removeMovie(_ movie: Movie) {
        savedMovies.removeAll { $0.id == movie.id }
    }

    func removeTVShow(_ show: TVShow) {
        savedTVShows.removeAll { $0.id == show.id }
    }
    
    func clearMovies() {
        savedMovies.removeAll()
    }
    
    func clearTVShows() {
        savedTVShows.removeAll()
    }

    private func saveMovies() {
        if let encoded = try? JSONEncoder().encode(savedMovies) {
            UserDefaults.standard.set(encoded, forKey: movieKey)
        }
    }

    private func saveTVShows() {
        if let encoded = try? JSONEncoder().encode(savedTVShows) {
            UserDefaults.standard.set(encoded, forKey: tvKey)
        }
    }

    private func loadMovies() {
        if let data = UserDefaults.standard.data(forKey: movieKey),
           let decoded = try? JSONDecoder().decode([Movie].self, from: data) {
            savedMovies = decoded
        }
    }

    private func loadTVShows() {
        if let data = UserDefaults.standard.data(forKey: tvKey),
           let decoded = try? JSONDecoder().decode([TVShow].self, from: data) {
            savedTVShows = decoded
        }
    }
}
