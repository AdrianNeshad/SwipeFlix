//
//  WatchList.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-01.
//

import SwiftUI

enum WatchListSegment: String, CaseIterable, Identifiable {
    case movies = "Movies"
    case tvShows = "TV Shows"
    var id: String { rawValue }
}

struct WatchList: View {
    @EnvironmentObject private var watchList: WatchListManager
    @State private var selectedSegment: WatchListSegment = .movies

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 10) {
                    if selectedSegment == .movies {
                        if watchList.savedMovies.isEmpty {
                            Text("No saved movies yet.")
                                .foregroundColor(.gray)
                                .padding(.top, 50)
                        } else {
                            ForEach(watchList.savedMovies) { movie in
                                WatchListRowView(
                                    title: movie.title,
                                    overview: movie.overview,
                                    imageURL: movie.posterURL,
                                    linkURL: nil
                                )
                            }
                        }
                    } else {
                        if watchList.savedTVShows.isEmpty {
                            Text("No saved TV shows yet.")
                                .foregroundColor(.gray)
                                .padding(.top, 50)
                        } else {
                            ForEach(watchList.savedMovies) { movie in
                                WatchListRowView(
                                    title: movie.title,
                                    overview: movie.overview,
                                    imageURL: movie.posterURL,
                                    linkURL: nil
                                )
                            }
                        }
                    }
                }
                .padding(.top, 10)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                           Text("Watchlist")
                               .font(.title2.bold())
                       }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker("", selection: $selectedSegment) {
                        Label("Movies", systemImage: "film").tag(WatchListSegment.movies)
                        Label("TV", systemImage: "tv").tag(WatchListSegment.tvShows)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 180)
                }
            }
        }
    }
}
