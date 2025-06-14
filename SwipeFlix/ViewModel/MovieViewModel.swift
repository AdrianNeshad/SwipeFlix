//
//  MovieViewModel.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-05-31.
//

import SwiftUI

enum MovieCategory: String, CaseIterable, Identifiable {
    case topRated = "top_rated"
    case popular = "popular"
    case now_playing = "now_playing"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .topRated: return "Top Rated"
        case .popular: return "Popular"
        case .now_playing: return "Latest"
        }
    }
}

class MovieViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var selectedCategory: MovieCategory = .topRated {
        didSet {
            fetch()
        }
    }

    func fetch() {
        movies = []
        let pageRange = 1...3
        var allResults: [Movie] = []
        let group = DispatchGroup()

        for page in pageRange {
            guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(selectedCategory.rawValue)?api_key=19deb7cbacfe2238a57278a1a57a43e6&page=\(page)") else { continue }

            group.enter()
            URLSession.shared.dataTask(with: url) { data, _, _ in
                defer { group.leave() }

                if let data = data,
                   let decoded = try? JSONDecoder().decode(MovieResponse.self, from: data) {
                    DispatchQueue.main.async {
                        allResults.append(contentsOf: decoded.results)
                    }
                }
            }.resume()
        }

        group.notify(queue: .main) {
            let uniqueResults = Array(Set(allResults))
            self.movies = uniqueResults.shuffled()
        }
    }

    func removeTop() {
        if !movies.isEmpty {
            movies.removeFirst()
        }
    }
}
