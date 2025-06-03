//
//  TVShowViewModel.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-05-31.
//

import SwiftUI

enum TVShowCategory: String, CaseIterable, Identifiable {
    case topRated = "top_rated"
    case popular = "popular"
    case airingToday = "airing_today"
    
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .topRated: return "Top Rated"
        case .popular: return "Popular"
        case .airingToday: return "Airing Today"
        }
    }
}

class TVShowViewModel: ObservableObject {
    @Published var shows: [TVShow] = []
    @Published var selectedCategory: TVShowCategory = .topRated {
        didSet {
            fetch()
        }
    }

    func fetch() {
        shows = []
        let pageRange = 1...3
        var allResults: [TVShow] = []
        let group = DispatchGroup()

        for page in pageRange {
            guard let url = URL(string: "https://api.themoviedb.org/3/tv/\(selectedCategory.rawValue)?api_key=19deb7cbacfe2238a57278a1a57a43e6&page=\(page)") else { continue }

            group.enter()
            URLSession.shared.dataTask(with: url) { data, _, _ in
                defer { group.leave() }

                if let data = data,
                   let decoded = try? JSONDecoder().decode(TVShowResponse.self, from: data) {
                    DispatchQueue.main.async {
                        allResults.append(contentsOf: decoded.results)
                    }
                }
            }.resume()
        }

        group.notify(queue: .main) {
            let uniqueResults = Array(Set(allResults))
            self.shows = uniqueResults.shuffled()
        }
    }

    func removeTop() {
        if !shows.isEmpty {
            shows.removeFirst()
        }
    }
}
