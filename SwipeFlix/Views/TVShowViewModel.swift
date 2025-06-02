//
//  TVShowViewModel.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-05-31.
//

import SwiftUI

class TVShowViewModel: ObservableObject {
    @Published var shows: [TVShow] = []

    func fetch() {
        let pageRange = 1...10
        var allResults: [TVShow] = []
        let group = DispatchGroup()

        for page in pageRange {
            guard let url = URL(string: "https://api.themoviedb.org/3/tv/top_rated?api_key=19deb7cbacfe2238a57278a1a57a43e6&page=\(page)") else { continue }

            group.enter()
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data,
                   let decoded = try? JSONDecoder().decode(TVShowResponse.self, from: data) {
                    DispatchQueue.main.async {
                        allResults.append(contentsOf: decoded.results)
                    }
                }
                group.leave()
            }.resume()
        }

        group.notify(queue: .main) {
            if self.shows.isEmpty {
                self.shows = allResults.shuffled()
            }
        }
    }

    func removeTop() {
        if !shows.isEmpty {
            shows.removeFirst()
        }
    }
}
