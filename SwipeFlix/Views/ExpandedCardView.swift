//
//  ExpandedCardView.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-02.
//

import SwiftUI
import YouTubePlayerKit
import Kingfisher

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
    @State private var youtubeVideoID: String?
    @State private var cast: [MovieDetails.CastMember] = []
    @State private var revenue: Int? = nil
    @State private var budget: Int? = nil
    @State private var logoURL: URL? = nil

    private var googleSearchURL: URL {
        let encoded = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://www.google.com/search?q=\(encoded)")!
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerImage
                infoSection
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $isPresentingSafari) {
            SafariView(url: googleSearchURL)
        }
        .onAppear {
            if isMovie {
                VideoService.shared.fetchYouTubeVideoID(forMovieId: id) { self.youtubeVideoID = $0 }
                VideoService.shared.fetchMovieDetails(for: id) { details in
                    self.revenue = details?.revenue
                    self.budget = details?.budget
                    self.cast = details?.credits?.cast ?? []
                }
                VideoService.shared.fetchLogoURL(forMovieId: id) { self.logoURL = $0 }
            } else {
                VideoService.shared.fetchYouTubeVideoID(forTVShowId: id) { self.youtubeVideoID = $0 }
                VideoService.shared.fetchTVShowDetails(for: id) { details in
                    self.cast = details?.credits?.cast ?? []
                }
                VideoService.shared.fetchLogoURL(forTVShowId: id) { self.logoURL = $0 }
            }
        }
    }

    private var headerImage: some View {
        ZStack(alignment: .bottomLeading) {
            KFImage(imageURL)
                .resizable()
                .scaledToFill()
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
                    if let logoURL = logoURL {
                        KFImage(logoURL)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 280)
                    } else {
                        Text(title)
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                            .lineLimit(2)
                    }

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
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "star.fill").foregroundColor(.yellow)
                Text(rating == nil || rating == 0.0 ? "N/A" : String(format: "%.1f", rating!))
                Text("•")
                Text(year ?? "Year")
                Text("•")
                Text(topGenre ?? "Genre")
            }
            .foregroundColor(.white.opacity(0.85))
            .font(.headline)

            Text(overview)
                .foregroundColor(.secondary)
                .font(.body)

            if let revenue = revenue, revenue > 0 {
                Text("Box Office: $\(revenue.formatted(.number.grouping(.automatic)))")
                    .font(.subheadline)
            }

            if let budget = budget, budget > 0 {
                Text("Budget: $\(budget.formatted(.number.grouping(.automatic)))")
                    .font(.subheadline)
            }
            
            if let videoID = youtubeVideoID {
                YouTubePlayerView(YouTubePlayer(source: .video(id: videoID)))
                    .frame(height: 200)
                    .cornerRadius(12)
            }
            if !cast.isEmpty {
                Text("Cast")
                    .font(.headline)
                    .foregroundColor(.white)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(cast.prefix(10)) { member in
                            VStack(alignment: .center, spacing: 4) {
                                KFImage(member.profileURL)
                                    .placeholder {
                                        Color.gray.opacity(0.3)
                                            .overlay(Image(systemName: "person.fill").font(.largeTitle))
                                    }
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                Text(member.name)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .lineLimit(1)

                                if !member.character.isEmpty {
                                    Text("as \(member.character)")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                            }
                            .frame(width: 90)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.black)
    }
}
