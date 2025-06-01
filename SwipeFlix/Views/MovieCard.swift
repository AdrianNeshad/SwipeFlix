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
        VStack(spacing: 0) {
            if let poster = movie.posterURL {
                ZStack(alignment: .bottom) {
                    AsyncImage(url: poster) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(height: 400)
                    .clipped()

                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black]),
                        startPoint: .center,    
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.title2)
                    .bold()
                Text(movie.overview)
                    .font(.body)
                    .lineLimit(5)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.systemBackground).opacity(0.95))
        }
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}
