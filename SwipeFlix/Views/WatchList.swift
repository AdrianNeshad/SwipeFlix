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
                        .listStyle(.plain)
                        .listRowSeparator(.hidden)
                        .padding(.top, 50)
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
                            .listStyle(.plain)
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
                        .listStyle(.plain)
                        .listRowSeparator(.hidden)
                        .padding(.top, 50)
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
                            .listStyle(.plain)
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
            .listRowSeparator(.hidden)
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
