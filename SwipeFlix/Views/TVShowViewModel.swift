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
        guard let url = URL(string: "https://api.themoviedb.org/3/tv/popular?api_key=19deb7cbacfe2238a57278a1a57a43e6") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let response = try? JSONDecoder().decode(TVShowResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.shows = response.results
                }
            }
        }.resume()
    }

    func removeTop() {
        if !shows.isEmpty {
            shows.removeFirst()
        }
    }
}
