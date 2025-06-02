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

    @State private var isPresentingSafari = false

    private var googleSearchURL: URL {
        let encoded = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://www.google.com/search?q=\(encoded)")!
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }

            VStack(spacing: 12) {
                // Poster image – clickable
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
                        Spacer()
                        Button {
                            isFavorite.toggle()
                        } label: {
                            Image(systemName: isFavorite ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .imageScale(.large)
                        }
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", rating ?? 0.0))
                            .bold()
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
