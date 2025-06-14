//
//  ExpandedCardView.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-02.
//

import SwiftUI
import YouTubePlayerKit

struct ExpandedCardView: View {
    let id: Int
    let isMovie: Bool
    let title: String
    let overview: String
    let imageURL: URL?
    let onClose: () -> Void
    @Binding var isFavorite: Bool
    let rating: Double?
    let year: String?
    let topGenre: String?

    @State private var isPresentingSafari = false
    @State private var isPresentingTrailer = false
    @State private var youtubeVideoID: String?

    private var googleSearchURL: URL {
        let encoded = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://www.google.com/search?q=\(encoded)")!
    }

    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.gray
                        }
                        .frame(height: 450)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .bottom) {
                                Text(title)
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)

                                Spacer()
                                HStack(spacing: 12) {
                                    Button {
                                        isFavorite.toggle()
                                    } label: {
                                        Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                                            .font(.title2)
                                            .padding(8)
                                            .background(Color.white.opacity(0.3))
                                            .foregroundColor(isFavorite ? .green : .white)
                                            .clipShape(Circle())
                                    }

                                    Button {
                                        isPresentingSafari = true
                                    } label: {
                                        Image(systemName: "globe")
                                            .font(.title2)
                                            .padding(8)
                                            .background(Color.white.opacity(0.3))
                                            .foregroundColor(.white)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding()
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)

                            Text(rating == nil || rating == 0.0 ? "N/A" : String(format: "%.1f", rating!))

                            Text("•")
                            Text("\(year ?? "Year")")
                            Text("•")
                            Text(topGenre ?? "Genre")
                        }
                        .foregroundColor(.white.opacity(0.85))
                        .font(.headline)

                        Text(overview)
                            .foregroundColor(.secondary)
                            .font(.body)
                        
                        if let videoID = youtubeVideoID {
                            VStack(spacing: 8) {
                                YouTubePlayerView(
                                    YouTubePlayer(source: .video(id: videoID))
                                )
                                .frame(height: 200)
                                .cornerRadius(12)
                            }
                        }
                        
                        Text("Cast, trailers, etc. coming soon...")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.black)
                }
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $isPresentingSafari) {
            SafariView(url: googleSearchURL)
        }
        .onAppear {
            if isMovie {
                VideoService.shared.fetchYouTubeVideoID(forMovieId: id) { videoID in
                    self.youtubeVideoID = videoID
                }
            } else {
                VideoService.shared.fetchYouTubeVideoID(forTVShowId: id) { videoID in
                    self.youtubeVideoID = videoID
                }
            }
        }
    }
}
