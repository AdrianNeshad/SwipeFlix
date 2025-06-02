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
    @StateObject private var viewModel = ExploreViewModel()
    @State private var selectedSegment: ExploreSegment = .movies

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if selectedSegment == .movies {
                        if !viewModel.topRated.isEmpty {
                            MovieRow(title: "Top Rated", movies: viewModel.topRated)
                        }
                        ForEach(viewModel.genreMovies.sorted(by: { $0.key < $1.key }), id: \.key) { genre, movies in
                            let shuffled = movies.shuffled()
                            MovieRow(title: genre, movies: shuffled)
                        }
                    } else {
                        if !viewModel.topRatedTV.isEmpty {
                            TVShowRow(title: "Top Rated", shows: viewModel.topRatedTV)
                        }
                        ForEach(viewModel.genreTVShows.sorted(by: { $0.key < $1.key }), id: \.key) { genre, shows in
                            let shuffled = shows.shuffled()
                            TVShowRow(title: genre, shows: shuffled)
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
                viewModel.fetchAll()
            }
        }
    }
}

struct MovieRow: View {
    let title: String
    let movies: [Movie]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3.bold())
                .padding(.leading, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(movies) { movie in
                        CompactMovieCard(title: movie.title, imageURL: movie.posterURLSmall)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3.bold())
                .padding(.leading, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(shows) { show in
                        CompactMovieCard(title: show.title, imageURL: show.posterURLSmall)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
}
