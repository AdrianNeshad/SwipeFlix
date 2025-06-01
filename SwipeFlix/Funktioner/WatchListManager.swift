//
//  WatchListManager.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-01.
//

import Foundation

class WatchListManager: ObservableObject {
    @Published var savedMovies: [Movie] = []
    @Published var savedTVShows: [TVShow] = []

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
}
