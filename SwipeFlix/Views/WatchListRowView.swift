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

    @State private var isPresentingSafari = false

    private var destinationURL: URL {
        if let linkURL = linkURL {
            return linkURL
        } else {
            let query = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return URL(string: "https://www.google.com/search?q=\(query)")!
        }
    }

    var body: some View {
        Button(action: {
            isPresentingSafari = true
        }) {
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: imageURL) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 100, height: 150)
                .cornerRadius(12)
                .clipped()
                .padding(.leading, 8)

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(overview)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(5)
                }

                Spacer()
            }
            .padding(.trailing, 10)
            .padding(.vertical, 6)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $isPresentingSafari) {
            SafariView(url: destinationURL)
        }
    }
}
