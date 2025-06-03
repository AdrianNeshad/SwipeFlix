//
//  ExpandedCardView.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-02.
//

import SwiftUI
import SafariServices

struct ExpandedCardView: View {
    let title: String
    let overview: String
    let imageURL: URL?
    let onClose: () -> Void
    @Binding var isFavorite: Bool
    let rating: Double?
    let year: String?
    let topGenre: String?

    @State private var isPresentingSafari = false

    private var googleSearchURL: URL {
        let encoded = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://www.google.com/search?q=\(encoded)")!
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }
            VStack(spacing: 12) {
                Button(action: {
                    isPresentingSafari = true
                }) {
                    AsyncImage(url: imageURL) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(maxHeight: 400)
                    .cornerRadius(16)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(title)
                            .font(.title)
                            .bold()
                            .lineLimit(2)
                        Spacer()
                        Button {
                            isFavorite.toggle()
                        } label: {
                            Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                                .foregroundColor(.green)
                                .imageScale(.large)
                        }
                    }

                    HStack(spacing: 6) {
                        Image("tmdb_large")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                        Text("•")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.white)
                        Text(String(year ?? ""))
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.white)
                        Text("•")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.white)
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", rating ?? 0.0))
                            .bold()
                        Text("•")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.white)
                        Text(String(topGenre ?? ""))
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.white)
                    }
                    .font(.subheadline)

                    Text(overview)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
            }
            .padding()
        }
        .transition(.opacity)
        .animation(.easeInOut, value: isFavorite)
        .sheet(isPresented: $isPresentingSafari) {
            SafariView(url: googleSearchURL)
        }
    }
}
