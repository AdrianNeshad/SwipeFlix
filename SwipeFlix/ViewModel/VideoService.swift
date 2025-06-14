//
//  VideoService.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-14.
//

import Foundation

class VideoService {
    static let shared = VideoService()
    private let apiKey = "19deb7cbacfe2238a57278a1a57a43e6"
    private init() {}

    func fetchYouTubeVideoID(forMovieId id: Int, completion: @escaping (String?) -> Void) {
        let urlString = "https://api.themoviedb.org/3/movie/\(id)/videos?api_key=\(apiKey)&language=en-US"
        fetchVideoID(from: urlString, completion: completion)
    }

    func fetchYouTubeVideoID(forTVShowId id: Int, completion: @escaping (String?) -> Void) {
        let urlString = "https://api.themoviedb.org/3/tv/\(id)/videos?api_key=\(apiKey)&language=en-US"
        fetchVideoID(from: urlString, completion: completion)
    }

    private func fetchVideoID(from urlString: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let response = try JSONDecoder().decode(VideoResponse.self, from: data)
                let video = response.results.first { $0.site == "YouTube" && $0.type.lowercased() == "trailer" }
                completion(video?.key)
            } catch {
                completion(nil)
            }
        }.resume()
    }
}
