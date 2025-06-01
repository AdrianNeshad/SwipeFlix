//
//  MovieCard.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-05-31.
//

import SwiftUI

struct MovieCard: View {
    let movie: Movie
    var tapAction: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let poster = movie.posterURL {
                AsyncImage(url: poster) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 320, height: 550)
                .clipped()
            }
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .black, location: 0.0),
                    .init(color: .black.opacity(0.95), location: 0.4),
                    .init(color: .clear, location: 0.6)
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 320)
            .frame(width: 320)

            VStack(alignment: .leading, spacing: 1) {
                Text(movie.title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)

                Text(movie.overview)
                    .font(.body)
                    .foregroundColor(.white)
                    .lineLimit(4)
            }
            .padding()
            .frame(width: 320, alignment: .leading)
            .padding(.bottom, 20)
        }
        .frame(width: 320, height: 550)
        .cornerRadius(16)
        .shadow(radius: 5)
        .frame(maxWidth: .infinity)
        .onTapGesture {
            tapAction?()
        }
    }
}
