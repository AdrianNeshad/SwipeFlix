//
//  ExpandedCardView.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-02.
//

import SwiftUI

struct ExpandedCardView: View {
    let title: String
    let overview: String
    let imageURL: URL?
    let onClose: () -> Void
    @Binding var isFavorite: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }

            VStack(spacing: 12) {
                AsyncImage(url: imageURL) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Color.gray
                }
                .frame(maxHeight: 400)
                .cornerRadius(16)

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
    }
}
