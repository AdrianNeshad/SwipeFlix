//
//  TVShowCard.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-05-31.
//

import SwiftUI

struct TVShowCard: View {
    let show: TVShow
    var tapAction: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let poster = show.posterURL {
                AsyncImage(url: poster) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 320, height: 550)
                .clipped()
            }
            VStack(alignment: .leading, spacing: 4) {
                if let year = show.releaseYear,
                   let rating = show.voteAverage {
                    let topGenre = show.genreNames.first ?? ""
                    let ratingText = String(format: "%.1f", rating)
                    HStack(spacing: 6) {
                        Image("tmdb_large")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("• \(year) •")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.white)
                        Image("imdb")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 14)
                        Text(ratingText)
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.white)
                        if !topGenre.isEmpty {
                            Text("• \(topGenre)")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.white)
                        }
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.top, 8)
                    .padding(.leading, 8)
                }

                Spacer()
            }
            .frame(width: 320, height: 550, alignment: .topLeading)

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
            .offset(y: 0)

            VStack(alignment: .leading, spacing: 1) {
                Text(show.title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)

                Text(show.overview)
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
