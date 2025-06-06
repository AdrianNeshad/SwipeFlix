//
//  MovieCardWrapper.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-06.
//

import SwiftUI

struct MovieCardWrapper: View {
    let movie: Movie
    var tapAction: (() -> Void)? = nil

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                MovieCard(movie: movie, tapAction: tapAction)
            } else {
                MovieCard_iPad(movie: movie, tapAction: tapAction)
            }
        }
    }
}
