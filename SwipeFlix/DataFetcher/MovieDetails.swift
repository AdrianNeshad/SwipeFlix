//
//  MovieDetails.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-14.
//

import Foundation

struct MovieDetails: Codable {
    let revenue: Int?
    let budget: Int?
    let credits: Credits?

    struct Credits: Codable {
        let cast: [CastMember]
    }

    struct CastMember: Codable, Identifiable {
        let id: Int
        let name: String
        let character: String
        let profile_path: String?

        var profileURL: URL? {
            guard let path = profile_path else { return nil }
            return URL(string: "https://image.tmdb.org/t/p/w185\(path)")
        }
    }
}
