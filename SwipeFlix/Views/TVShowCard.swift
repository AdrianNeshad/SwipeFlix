//
//  TVShowCard.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-05-31.
//

import SwiftUI

struct TVShowCard: View {
    let show: TVShow

    var body: some View {
        VStack(spacing: 0) {
            if let url = show.posterURL {
                ZStack(alignment: .bottom) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(height: 400)
                    .clipped()

                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black]),
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(show.title)
                    .font(.title2)
                    .bold()
                Text(show.overview)
                    .font(.body)
                    .lineLimit(5)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.systemBackground).opacity(0.95))
        }
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}
