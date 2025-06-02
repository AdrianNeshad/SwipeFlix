//
//  CompactMovieCard.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-02.
//

import SwiftUI

struct CompactMovieCard: View {
    let title: String
    let imageURL: URL?
    var tapAction: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            AsyncImage(url: imageURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray
            }
            .frame(width: 100, height: 150)
            .clipped()
            .cornerRadius(8)

            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(1)
                .frame(width: 100, alignment: .leading)
        }
        .onTapGesture {
            tapAction?()
        }
    }
}
