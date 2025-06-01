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
        let pageRange = 1...3
        var allResults: [Movie] = []
        let group = DispatchGroup()

        for page in pageRange {
            guard let url = URL(string: "https://api.themoviedb.org/3/movie/top_rated?api_key=19deb7cbacfe2238a57278a1a57a43e6&page=\(page)") else { continue }

            group.enter()
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data,
                   let decoded = try? JSONDecoder().decode(MovieResponse.self, from: data) {
                    DispatchQueue.main.async {
                        allResults.append(contentsOf: decoded.results)
                    }
                }
                group.leave()
            }.resume()
        }

        group.notify(queue: .main) {
            self.movies = allResults.shuffled()
        }
    }



    func removeTop() {
        if !movies.isEmpty {
            movies.removeFirst()
        }
    }
}
