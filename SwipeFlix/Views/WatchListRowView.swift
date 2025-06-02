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
    @State private var isExpanded = false

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
                    .foregroundColor(.primary)

                Group {
                    if isExpanded {
                        Text(overview)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .transition(.opacity)
                    } else {
                        Text(overview)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(4)
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: isExpanded)
            }
            Spacer()
        }
        .padding(.trailing, 10)
        .padding(.vertical, 6)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .onTapGesture {
            isExpanded.toggle()
        }
        .contextMenu {
            Button {
                isPresentingSafari = true
            } label: {
                Label("More info", systemImage: "globe")
            }
        }
        .sheet(isPresented: $isPresentingSafari) {
            SafariView(url: destinationURL)
        }
    }
}
