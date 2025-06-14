//
//  TVShowCard_iPad.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-06.
//

import SwiftUI

struct TVShowCard_iPad: View {
    let show: TVShow
    var tapAction: (() -> Void)? = nil
    
    @State private var isExpanded = false

    var body: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width
            let cardHeight = geometry.size.height

            ZStack(alignment: .bottomLeading) {
                if let poster = show.posterURL {
                    AsyncImage(url: poster) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: cardWidth, height: cardHeight)
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
                        Text(show.title)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)

                        Text(show.overview)
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
                    .frame(width: 320, height: 550)
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
