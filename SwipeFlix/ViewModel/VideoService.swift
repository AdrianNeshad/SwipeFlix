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
                DispatchQueue.main.async {
                    completion(video?.key)
                }
            } catch {
                print("Video decode error:", error)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }

    func fetchMovieDetails(for id: Int, completion: @escaping (MovieDetails?) -> Void) {
        let urlStr = "https://api.themoviedb.org/3/movie/\(id)?api_key=\(apiKey)&append_to_response=credits"
        fetchDetails(from: urlStr, completion: completion)
    }

    func fetchTVShowDetails(for id: Int, completion: @escaping (MovieDetails?) -> Void) {
        let urlStr = "https://api.themoviedb.org/3/tv/\(id)?api_key=\(apiKey)&append_to_response=credits"
        fetchDetails(from: urlStr, completion: completion)
    }

    private func fetchDetails(from urlStr: String, completion: @escaping (MovieDetails?) -> Void) {
        guard let url = URL(string: urlStr) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let details = try JSONDecoder().decode(MovieDetails.self, from: data)
                DispatchQueue.main.async {
                    completion(details)
                }
            } catch {
                print("Details decode error:", error)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    func fetchLogoURL(forMovieId id: Int, completion: @escaping (URL?) -> Void) {
        let urlStr = "https://api.themoviedb.org/3/movie/\(id)/images?api_key=\(apiKey)&include_image_language=en,null"
        guard let url = URL(string: urlStr) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }
            do {
                let response = try JSONDecoder().decode(ImagesResponse.self, from: data)
                if let logoPath = response.logos.first?.file_path {
                    let url = URL(string: "https://image.tmdb.org/t/p/original\(logoPath)")
                    DispatchQueue.main.async {
                        completion(url)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } catch {
                print("Logo decode error:", error)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    func fetchLogoURL(forTVShowId id: Int, completion: @escaping (URL?) -> Void) {
        let urlStr = "https://api.themoviedb.org/3/tv/\(id)/images?api_key=\(apiKey)&include_image_language=en,null"
        guard let url = URL(string: urlStr) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }
            do {
                let response = try JSONDecoder().decode(ImagesResponse.self, from: data)
                if let logoPath = response.logos.first?.file_path {
                    let url = URL(string: "https://image.tmdb.org/t/p/original\(logoPath)")
                    DispatchQueue.main.async {
                        completion(url)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } catch {
                print("TV Logo decode error:", error)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }


    struct ImagesResponse: Codable {
        let logos: [Logo]

        struct Logo: Codable {
            let file_path: String
            let language: String?
        }
    }

}
