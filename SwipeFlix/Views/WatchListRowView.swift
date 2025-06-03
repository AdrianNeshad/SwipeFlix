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
            VStack {
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
                
                Group {
                    if isExpanded {
                        VStack(spacing: 5) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", rating ?? 0.0))
                                    .bold()
                            }
                            Text(String(topGenre ?? ""))
                                .bold()
                                .foregroundColor(.white)
                            Text(String(year ?? ""))
                                    .bold()
                                    .foregroundColor(.white)
                        }
                    }
                }
                .animation(.linear(duration: 0.3), value: isExpanded)
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.headline)
                }
                Group {
                    Text(overview)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(isExpanded ? nil : 4)
                        .transition(.opacity)
                    HStack {
                        Spacer()
                        Text(isExpanded ? "Show less" : "Show more")
                            .font(.subheadline)
                    }
                }
                .animation(.linear(duration: 0.3), value: isExpanded)
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
