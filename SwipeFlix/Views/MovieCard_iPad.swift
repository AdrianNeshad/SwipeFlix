//
//  MovieCard_iPad.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-06.
//

import SwiftUI
import Kingfisher

struct MovieCard_iPad: View {
    let movie: Movie
    var tapAction: (() -> Void)? = nil

    @State private var isExpanded = false

    var body: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width
            let cardHeight = geometry.size.height

            ZStack(alignment: .bottomLeading) {
                if let poster = movie.posterURL {
                    KFImage(poster)
                        .resizable()
                        .placeholder {
                            Color.gray
                        }
                        .scaledToFill()
                        .frame(width: cardWidth, height: cardHeight)
                        .clipped()
                }

                VStack(alignment: .leading, spacing: 4) {
                    if let year = movie.releaseYear,
                       let rating = movie.voteAverage {
                        let topGenre = movie.genreNames.first ?? ""
                        let ratingText = rating == 0.0 ? "N/A" : String(format: "%.1f", rating)
                        HStack(spacing: 6) {
                            Image("tmdb_large")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 20)
                            Text("• \(year) •")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.white)
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .frame(width: 20, height: 20)
                            Text(ratingText)
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(rating == 0.0 ? .gray : .yellow)
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
                .frame(width: cardWidth, height: cardHeight, alignment: .topLeading)

                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .black, location: 0.0),
                        .init(color: .black.opacity(0.95), location: 0.4),
                        .init(color: .clear, location: 0.6)
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: cardHeight * 0.6)
                .frame(width: cardWidth)

                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(movie.title)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)

                        Text(movie.overview)
                            .font(.body)
                            .foregroundColor(.white)
                            .lineLimit(isExpanded ? 20 : 5)
                    }
                    .padding()
                    .frame(width: cardWidth, alignment: .leading)
                    .background(Color.black.opacity(isExpanded ? 0.85 : 0)
                        .animation(.easeInOut(duration: 0.2), value: isExpanded))
                    .cornerRadius(16)
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.35)) {
                            isExpanded.toggle()
                        }
                    }
                }
                .frame(width: cardWidth, height: isExpanded ? cardHeight : cardHeight * 0.3, alignment: .bottom)
                .offset(y: -15)

                Color.clear
                    .frame(width: cardWidth, height: cardHeight)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        tapAction?()
                    }
            }
            .cornerRadius(16)
            .shadow(radius: 5)
        }
    }
}
