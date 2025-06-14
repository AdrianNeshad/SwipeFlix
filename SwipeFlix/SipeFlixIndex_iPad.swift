//
//  SipeFlixIndex_iPad.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-06.
//

import SwiftUI

struct SwipeFlixIndex_iPad: View {
    @EnvironmentObject private var watchList: WatchListManager
    @EnvironmentObject private var movieVM: MovieViewModel
    @EnvironmentObject private var tvShowVM: TVShowViewModel

    @Binding var selectedIndex: Int
    @Binding var triggerSwipe: Bool
    @Binding var swipeDirection: SwipeDirection?
    @Binding var selectedSearchURL: URL?
    @Binding var showToast: Bool
    @Binding var toastText: String

    @State private var selectedExpandedMovie: Movie? = nil
    @State private var selectedExpandedTVShow: TVShow? = nil

    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                Spacer(minLength: 150)
                ZStack {
                    swipeCardStack()
                }
                .frame(height: UIScreen.main.bounds.height * 0.75)
                .padding(.bottom, 40)
                .offset(y: -20)
                .zIndex(0)
            }
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 160)
                    .edgesIgnoringSafeArea(.top)
                    .zIndex(0.5)

                Spacer(minLength: 0)

                Rectangle()
                    .fill(Color.black)
                    .frame(height: 100)
                    .edgesIgnoringSafeArea(.bottom)
                    .zIndex(0.5)
                    .offset(y: 40)
            }
            .frame(maxHeight: .infinity)

            HStack(spacing: 60) {
                Button(action: swipeLeft) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                }

                Button(action: swipeRight) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                }
            }
            .offset(y: UIScreen.main.bounds.height * 0.825)
            .zIndex(1)

            if showToast {
                HStack(spacing: 8) {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(.green)
                    Text(toastText)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(Color.black.opacity(0.95))
                .cornerRadius(12)
                .padding(.top, 100)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(2)
            }

            VStack(spacing: 20) {
                Text("FlixSwipe")
                    .font(.largeTitle.bold())
                    .padding(.top, 50)
                ZStack {
                    HBSegmentedPicker(
                        selectedIndex: $selectedIndex,
                        items: SwipeContentType.allCases.map { $0.rawValue }
                    )
                    .frame(width: 260, height: 40)

                    HStack {
                        Spacer()
                        Menu {
                            switch SwipeContentType.allCases[selectedIndex] {
                            case .movies:
                                ForEach(MovieCategory.allCases) { category in
                                    Button {
                                        movieVM.selectedCategory = category
                                    } label: {
                                        HStack {
                                            Text(category.displayName)
                                            Spacer()
                                            if movieVM.selectedCategory == category {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            case .tvShows:
                                ForEach(TVShowCategory.allCases) { category in
                                    Button {
                                        tvShowVM.selectedCategory = category
                                    } label: {
                                        HStack {
                                            Text(category.displayName)
                                            Spacer()
                                            if tvShowVM.selectedCategory == category {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            Label("", systemImage: "line.3.horizontal.decrease.circle")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        .padding(.leading, 8)
                        .padding(.trailing, 200)
                    }
                }
                .frame(height: 40)
            }
            .zIndex(1)
        }
        .sheet(item: $selectedExpandedMovie) { movie in
            ExpandedCardView(
                id: movie.id,
                isMovie: true,
                title: movie.title,
                overview: movie.overview,
                imageURL: movie.posterURL,
                onClose: { selectedExpandedMovie = nil },
                isFavorite: Binding(
                    get: { watchList.containsMovie(movie) },
                    set: { isFav in
                        if isFav {
                            watchList.addMovie(movie)
                        } else {
                            watchList.removeMovie(movie)
                        }
                    }
                ),
                rating: movie.voteAverage,
                year: movie.releaseYear,
                topGenre: movie.genreNames.first
            )
        }
        .sheet(item: $selectedExpandedTVShow) { show in
            ExpandedCardView(
                id: show.id,
                isMovie: false,
                title: show.title,
                overview: show.overview,
                imageURL: show.posterURL,
                onClose: { selectedExpandedTVShow = nil },
                isFavorite: Binding(
                    get: { watchList.containsTVShow(show) },
                    set: { isFav in
                        if isFav {
                            watchList.addTVShow(show)
                        } else {
                            watchList.removeTVShow(show)
                        }
                    }
                ),
                rating: show.voteAverage,
                year: show.releaseYear,
                topGenre: show.genreNames.first
            )
        }
        .onAppear {
            movieVM.fetch()
            tvShowVM.fetch()
        }
    }

    private func swipeLeft() {
        swipeDirection = .left
        triggerSwipe = true
    }

    private func swipeRight() {
        swipeDirection = .right
        triggerSwipe = true
    }

    private func swipeCardStack() -> some View {
        let selectedType = SwipeContentType.allCases[selectedIndex]
        switch selectedType {
        case .movies:
            return AnyView(
                swipeStack(items: movieVM.movies, onRemove: { liked, movie in
                    if liked {
                        watchList.addMovie(movie)
                        showToast(text: "Added to Watchlist")
                    }
                    movieVM.removeTop()
                }) { movie in
                    MovieCard(movie: movie) {
                        selectedExpandedMovie = movie
                    }
                }
            )
        case .tvShows:
            return AnyView(
                swipeStack(items: tvShowVM.shows, onRemove: { liked, show in
                    if liked {
                        watchList.addTVShow(show)
                        showToast(text: "Added to Watchlist")
                    }
                    tvShowVM.removeTop()
                }) { show in
                    TVShowCard(show: show) {
                        selectedExpandedTVShow = show
                    }
                }
            )
        }
    }

    private func swipeStack<T: Identifiable, Content: View>(
        items: [T],
        onRemove: @escaping (Bool, T) -> Void,
        @ViewBuilder content: @escaping (T) -> Content
    ) -> some View {
        ZStack {
            if items.isEmpty {
                Text("No more cards")
                    .font(.title)
                    .foregroundColor(.gray)
            } else {
                ForEach(Array(items.prefix(5).enumerated()), id: \.1.id) { index, item in
                    SwipeCard(
                        triggerSwipe: index == 0 ? $triggerSwipe : .constant(false),
                        swipeDirection: index == 0 ? $swipeDirection : .constant(nil),
                        content: {
                            content(item)
                        },
                        onRemove: { liked in
                            onRemove(liked, item)
                        }
                    )
                    .zIndex(Double(-index))
                    .padding(8)
                }
            }
        }
    }

    private func showToast(text: String) {
        toastText = text
        withAnimation {
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showToast = false
            }
        }
    }
}
