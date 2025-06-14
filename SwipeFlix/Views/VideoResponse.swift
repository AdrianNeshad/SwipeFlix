//
//  VideoResponse.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-14.
//

import Foundation

struct VideoResponse: Codable {
    let results: [Video]
}

struct Video: Codable, Identifiable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
}
