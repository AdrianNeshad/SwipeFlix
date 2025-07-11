//
//  NewsViewItem.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-01.
//

import SwiftUI

struct NewsItemView: View {
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("appLanguage") private var appLanguage = "sv"
    @State private var showingShareSheet = false
    
    let newsItem: NewsItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                if let logo = newsItem.source.logo {
                    Image(logo)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                }
                Text(newsItem.source.name)
                    .font(.headline)
                Spacer()

                if let date = newsItem.pubDate {
                    VStack {
                        Text(dateFormatted(date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.top, -5)
                }
            }
            .padding([.top, .horizontal])
            .padding(.bottom, 5)

            if let imageURL = newsItem.imageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, minHeight: 150, maxHeight: 150)
                        .clipped()
                        .cornerRadius(10)
                        .padding(.horizontal)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.3))
                        .frame(maxWidth: .infinity, minHeight: 150, maxHeight: 150)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            Text(newsItem.title)
                .font(.title3)
                .bold()
                .padding(.horizontal)

            Text(newsItem.description)
                .font(.body)
                .lineLimit(12)
                .padding([.horizontal, .bottom])
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isDarkMode ? Color.gray.opacity(0.15) : Color(white: 0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isDarkMode ? Color.gray.opacity(0.5) : Color.black, lineWidth: 1)
                )
        )
        .padding(.top, 10)
        .contextMenu {
            Button {
                showingShareSheet = true
            } label: {
                Label(appLanguage == "sv" ? "Dela artikel" : "Share Article", systemImage: "square.and.arrow.up")
            }
            Button {
                    if let url = newsItem.link {
                        UIPasteboard.general.string = url.absoluteString
                    }
                } label: {
                    Label(appLanguage == "sv" ? "Kopiera länk" : "Copy Link", systemImage: "doc.on.doc")
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = newsItem.link {
                ShareSheet(activityItems: [url])
                    .presentationDetents([.medium])
            }
        }
    }

    private func dateFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: appLanguage == "sv" ? "sv_SE" : "en_US")
        return formatter.string(from: date)
    }
}
