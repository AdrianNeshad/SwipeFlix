//
//  NewsCategory.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-01.
//

import SwiftUI
import Foundation

enum Category: String, CaseIterable, Identifiable {
    case movie = "Movies"
    
    var id: String { self.rawValue }

    var sources: [NewsSource] {
        switch self {
        case .movie:
            return [
                NewsSource(name: "FirstShowing", logo: nil),
                NewsSource(name: "Slashfilm", logo: nil),
                NewsSource(name: "Collider", logo: nil),
                NewsSource(name: "The Wrap", logo: nil),
            ]
        }
    }
    
    func localizedName(language: String) -> String {
        switch self {
        case .movie:
            return "News Feed"
        }
    }
}
