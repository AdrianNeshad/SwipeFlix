//
//  Explore.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-01.
//

import SwiftUI

enum ExploreSegment: String, CaseIterable, Identifiable {
    case movies = "Movies"
    case tvShows = "TV Shows"
    var id: String { rawValue }
}

struct Explore: View {
    @EnvironmentObject private var watchList: WatchListManager
    @AppStorage("watchlistMovies") private var watchlistMoviesString: String = "[]"
    @AppStorage("watchlistTV") private var watchlistTVString: String = "[]"
    @StateObject private var viewModel = ExploreViewModel()
    @State private var selectedSegment: ExploreSegment = .movies
    @State private var selectedMovie: Movie? = nil
    @State private var selectedTVShow: TVShow? = nil
    @State private var movieIDs: [Int] = []
    @State private var tvIDs: [Int] = []

    private var watchlistMovieIDs: [Int] {
        get {
            (try? JSONDecoder().decode([Int].self, from: Data(watchlistMoviesString.utf8))) ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let string = String(data: data, encoding: .utf8) {
                watchlistMoviesString = string
            }
        }
    }

    private var watchlistTVIDs: [Int] {
        get {
            (try? JSONDecoder().decode([Int].self, from: Data(watchlistTVString.utf8))) ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let string = String(data: data, encoding: .utf8) {
                watchlistTVString = string
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if selectedSegment == .movies {
                            if !viewModel.topRated.isEmpty {
                                MovieRow(title: "Top Rated", movies: viewModel.topRated) { movie in
                                    withAnimation { selectedMovie = movie }
                                }
                            }

                            if !viewModel.trendingMovies.isEmpty {
                                MovieRow(title: "Trending", movies: viewModel.trendingMovies) { movie in
                                    withAnimation { selectedMovie = movie }
                                }
                            }

                            if !viewModel.popularMovies.isEmpty {
                                MovieRow(title: "Popular", movies: viewModel.popularMovies) { movie in
                                    withAnimation { selectedMovie = movie }
                                }
                            }

                            ForEach(viewModel.genreMovies.sorted(by: { $0.key < $1.key }), id: \.key) { genre, movies in
                                MovieRow(title: genre, movies: movies) { movie in
                                    withAnimation { selectedMovie = movie }
                                }
                            }
                        } else {
                            if !viewModel.topRatedTV.isEmpty {
                                TVShowRow(title: "Top Rated", shows: viewModel.topRatedTV) { show in
                                    withAnimation { selectedTVShow = show }
                                }
                            }

                            if !viewModel.trendingTVShows.isEmpty {
                                TVShowRow(title: "Trending", shows: viewModel.trendingTVShows) { show in
                                    withAnimation { selectedTVShow = show }
                                }
                            }

                            if !viewModel.popularTVShows.isEmpty {
                                TVShowRow(title: "Popular", shows: viewModel.popularTVShows) { show in
                                    withAnimation { selectedTVShow = show }
                                }
                            }

                            ForEach(viewModel.genreTVShows.sorted(by: { $0.key < $1.key }), id: \.key) { genre, shows in
                                TVShowRow(title: genre, shows: shows) { show in
                                    withAnimation { selectedTVShow = show }
                                }
                            }
                        }
                    }
                    .padding()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("Explore")
                            .font(.title2.bold())
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Picker("", selection: $selectedSegment) {
                            Label("Movies", systemImage: "film").tag(ExploreSegment.movies)
                            Label("TV", systemImage: "tv").tag(ExploreSegment.tvShows)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 180)
                    }
                }
                .onAppear {
                    movieIDs = watchlistMovieIDs
                    tvIDs = watchlistTVIDs
                }

                if let movie = selectedMovie {
                    ExpandedCardView(
                        title: movie.title,
                        overview: movie.overview,
                        imageURL: movie.posterURL,
                        onClose: { selectedMovie = nil },
                        isFavorite: Binding(
                            get: {
                                watchList.savedMovies.contains(where: { $0.id == movie.id })
                            },
                            set: { newValue in
                                if newValue {
                                    watchList.addMovie(movie)
                                } else {
                                    watchList.removeMovie(movie)
                                }

                                movieIDs = watchList.savedMovies.map { $0.id }
                                if let data = try? JSONEncoder().encode(movieIDs),
                                   let string = String(data: data, encoding: .utf8) {
                                    watchlistMoviesString = string
                                }
                            }
                        ),
                        rating: movie.voteAverage,
                        year: movie.releaseYear,
                        topGenre: movie.genreNames.first
                    )
                } else if let show = selectedTVShow {
                    ExpandedCardView(
                        title: show.name,
                        overview: show.overview,
                        imageURL: show.posterURL,
                        onClose: { selectedTVShow = nil },
                        isFavorite: Binding(
                            get: {
                                watchList.savedTVShows.contains(where: { $0.id == show.id })
                            },
                            set: { newValue in
                                if newValue {
                                    watchList.addTVShow(show)
                                } else {
                                    watchList.removeTVShow(show)
                                }

                                tvIDs = watchList.savedTVShows.map { $0.id }
                                if let data = try? JSONEncoder().encode(tvIDs),
                                   let string = String(data: data, encoding: .utf8) {
                                    watchlistTVString = string
                                }
                            }
                        ),
                        rating: show.voteAverage,
                        year: show.releaseYear,
                        topGenre: show.genreNames.first
                    )
                }
            }
        }
    }
}

struct MovieRow: View {
    let title: String
    let movies: [Movie]
    var onTap: ((Movie) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.title3.bold()).padding(.leading, 8)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(movies) { movie in
                        CompactMovieCard(title: movie.title, imageURL: movie.posterURLSmall) {
                            onTap?(movie)
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
}

struct TVShowRow: View {
    let title: String
    let shows: [TVShow]
    var onTap: ((TVShow) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.title3.bold()).padding(.leading, 8)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(shows) { show in
                        CompactMovieCard(title: show.title, imageURL: show.posterURLSmall) {
                            onTap?(show)
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
}
