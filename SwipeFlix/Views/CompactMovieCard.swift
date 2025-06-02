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
