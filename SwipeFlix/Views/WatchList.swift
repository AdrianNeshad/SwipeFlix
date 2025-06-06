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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedSegment: WatchListSegment = .movies

    var isPad: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        NavigationStack {
            Group {
                if isPad {
                    // iPad: Rubrik och segmentkontroll i VStack
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Watchlist")
                            .font(.title2.bold())
                            .padding(.top)
                            .padding(.horizontal)

                        Picker("", selection: $selectedSegment) {
                            Label("Movies", systemImage: "film").tag(WatchListSegment.movies)
                            Label("TV", systemImage: "tv").tag(WatchListSegment.tvShows)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        .padding(.bottom, 8)

                        contentList
                    }
                } else {
                    // iPhone: Rubrik i navigationBarLeading, segment i navigationBarTrailing
                    contentList
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
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var contentList: some View {
        List {
            if selectedSegment == .movies {
                if watchList.savedMovies.isEmpty {
                    HStack {
                        Spacer()
                        Text("No saved movies yet")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding(.top, 50)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(watchList.savedMovies) { movie in
                        WatchListRowView(
                            title: movie.title,
                            overview: movie.overview,
                            imageURL: movie.posterURLSmall,
                            linkURL: nil,
                            rating: movie.voteAverage,
                            year: movie.releaseYear,
                            topGenre: movie.genreNames.first
                        )
                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 12))
                        .listRowSeparator(.hidden)
                        .swipeActions {
                            Button(role: .destructive) {
                                watchList.removeMovie(movie)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            } else {
                if watchList.savedTVShows.isEmpty {
                    HStack {
                        Spacer()
                        Text("No saved TV shows yet")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding(.top, 50)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(watchList.savedTVShows) { tvShow in
                        WatchListRowView(
                            title: tvShow.title,
                            overview: tvShow.overview,
                            imageURL: tvShow.posterURLSmall,
                            linkURL: nil,
                            rating: tvShow.voteAverage,
                            year: tvShow.releaseYear,
                            topGenre: tvShow.genreNames.first
                        )
                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 12))
                        .listRowSeparator(.hidden)
                        .swipeActions {
                            Button(role: .destructive) {
                                watchList.removeTVShow(tvShow)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}
