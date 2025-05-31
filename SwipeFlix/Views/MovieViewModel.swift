//
//  MovieViewModel.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-05-31.
//

import SwiftUI

class MovieViewModel: ObservableObject {
    @Published var movies: [Movie] = []

    func fetch() {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=19deb7cbacfe2238a57278a1a57a43e6") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(MovieResponse.self, from: data)
                DispatchQueue.main.async {
                    self.movies = decoded.results
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }

    func removeTop() {
        if !movies.isEmpty {
            movies.removeFirst()
        }
    }
}
