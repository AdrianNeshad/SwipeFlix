//
//  MovieCard.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-05-31.
//

import SwiftUI

struct MovieCard: View {
    let movie: Movie

    var body: some View {
        VStack {
            if let poster = movie.posterURL {
                AsyncImage(url: poster) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .frame(height: 400)
                .clipped()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.title2)
                    .bold()
                Text(movie.overview)
                    .font(.body)
                    .lineLimit(3)
            }
            .padding()
            .background(Color(UIColor.systemBackground).opacity(0.9))
        }
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}
