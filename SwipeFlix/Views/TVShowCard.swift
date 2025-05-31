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
        VStack {
            if let url = show.posterURL {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .frame(height: 400)
                .clipped()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(show.title)
                    .font(.title2)
                    .bold()
                Text(show.overview)
                    .font(.body)
                    .lineLimit(3)
            }
            .padding()
            .background(Color(UIColor.systemBackground).opacity(0.9))
        }
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}
