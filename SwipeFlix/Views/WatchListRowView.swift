//
//  WatchListRowView.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-01.
//

import SwiftUI

struct WatchListRowView: View {
    let title: String
    let overview: String
    let imageURL: URL?
    let linkURL: URL?
    let rating: Double?
    let year: String?
    let topGenre: String?

    @State private var isPresentingSafari = false
    @State private var isPresentingShareSheet = false

    private var destinationURL: URL {
        if let linkURL = linkURL {
            return linkURL
        } else {
            let query = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return URL(string: "https://www.google.com/search?q=\(query)")!
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    Color.gray
                        .frame(width: 100, height: 150)

                case .success(let image):
                    image
                        .resizable()
                        .interpolation(.low)
                        .antialiased(false)
                        .scaledToFit()
                        .frame(width: 100, height: 150)

                case .failure:
                    Color.gray
                        .frame(width: 100, height: 150)

                @unknown default:
                    Color.black
                        .frame(width: 100, height: 150)
                }
            }
            .frame(width: 100, height: 150)
            .cornerRadius(12)
            .clipped()
            .padding(.leading, 8)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                Text(overview)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(4)

                HStack(spacing: 4) {
                    let ratingText = (rating ?? 0.0) == 0.0 ? "N/A" : String(format: "%.1f", rating ?? 0.0)
                    let isValidRating = (rating ?? 0.0) > 0.0

                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)

                    Text(ratingText)
                        .bold()

                    Text("•")
                        .padding(.leading, 5)
                        .font(.title)

                    if let genre = topGenre, !genre.isEmpty {
                        Text(genre)
                            .foregroundColor(.white)
                            .font(.callout)
                            .bold()
                            .padding(.leading, 5)

                        Text("•")
                            .padding(.leading, 5)
                            .font(.title)
                    }

                    if let year {
                        Text(year)
                            .foregroundColor(.white)
                            .font(.callout)
                            .bold()
                            .padding(.leading, 5)
                    }
                }
            }

            Spacer()
        }
        .padding(.trailing, 10)
        .padding(.vertical, 6)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .contextMenu {
            Button {
                isPresentingSafari = true
            } label: {
                Label("More info", systemImage: "globe")
            }

            Button {
                isPresentingShareSheet = true
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
        .sheet(isPresented: $isPresentingSafari) {
            SafariView(url: destinationURL)
        }
        .sheet(isPresented: $isPresentingShareSheet) {
            ShareSheet(activityItems: [title, destinationURL])
                .presentationDetents([.medium])
        }
    }
}
