//
//   SwipeFlixIndex.swift
//   SwipeFlix
//
//   Created by Adrian Neshad on 2025-06-06.
//

import SwiftUI

enum SwipeContentType: String, CaseIterable, Identifiable {
    case movies = "Movies"
    case tvShows = "TV Shows"
    var id: String { rawValue }
}

enum SwipeDirection {
    case left, right
}

enum SwipeCardItem: Identifiable {
    case movie(Movie)
    case tvShow(TVShow)
    case ad(UUID = UUID())

    var id: UUID {
        switch self {
        case .movie(let movie):
            // Använd movie.id om den är unik och stabil, annars UUID(uuidString: "movie-\(movie.id)") ?? UUID()
            return UUID(uuidString: "movie-\(movie.id)") ?? UUID()
        case .tvShow(let show):
            // Använd show.id om den är unik och stabil, annars UUID(uuidString: "show-\(show.id)") ?? UUID()
            return UUID(uuidString: "show-\(show.id)") ?? UUID()
        case .ad(let id):
            return id
        }
    }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

struct SwipeFlixIndex: View {
    @EnvironmentObject private var watchList: WatchListManager
    @AppStorage("AdsRemoved") private var AdsRemoved = false
    @StateObject private var storeManager = StoreManager()
    @StateObject private var movieVM = MovieViewModel()
    @StateObject private var tvShowVM = TVShowViewModel()
    @StateObject private var nativeAdVM = NativeAdViewModel()

    @State private var selectedTab = 0
    @State private var selectedIndex = 0
    @State private var showToast = false
    @State private var toastText = ""
    @State private var selectedSearchURL: URL? = nil
    @State private var triggerSwipe = false
    @State private var swipeDirection: SwipeDirection? = nil

    @State private var selectedExpandedMovie: Movie? = nil
    @State private var selectedExpandedTVShow: TVShow? = nil
    @State private var swipeItems: [SwipeCardItem] = []

    private var selectedType: SwipeContentType {
        get { SwipeContentType.allCases[selectedIndex] }
        set {
            if let index = SwipeContentType.allCases.firstIndex(of: newValue) {
                selectedIndex = index
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            swipeTabView()
                .environmentObject(watchList)
                .environmentObject(movieVM)
                .environmentObject(tvShowVM)
                .tabItem {
                    Label("Swipe", systemImage: "hand.point.right.fill")
                }
                .tag(0)

            WatchList()
                .tabItem {
                    Label("Watchlists", systemImage: "list.bullet.rectangle")
                }
                .tag(1)

            Explore()
                .tabItem {
                    Label("Explore", systemImage: "square.stack.3d.up.fill")
                }
                .tag(2)

            NewsIndex()
                .tabItem {
                    Label("News Feed", systemImage: "newspaper")
                }
                .tag(3)

            Settings()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .sheet(item: $selectedSearchURL) { url in
            SafariView(url: url)
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
        .background(Color.black.ignoresSafeArea(edges: .bottom))
    }

    private func swipeTabView() -> some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                SwipeFlixIndex_iPad(
                    selectedIndex: $selectedIndex,
                    triggerSwipe: $triggerSwipe,
                    swipeDirection: $swipeDirection,
                    selectedSearchURL: $selectedSearchURL,
                    showToast: $showToast,
                    toastText: $toastText
                )
            } else {
                swipeViewContent
            }
        }
    }

    private var swipeViewContent: some View {
        ZStack(alignment: .top) {
            VStack {
                Spacer(minLength: 150)
                ZStack {
                    swipeCardStack()
                }
                .frame(height: UIScreen.main.bounds.height * 0.75)
                .padding(.bottom, 40)
                .offset(y: -70)
                .zIndex(0)
            }
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 120)
                    .edgesIgnoringSafeArea(.top)
                    .zIndex(0.5)

                Spacer(minLength: 0)

                Rectangle()
                    .fill(Color.black)
                    .frame(height: 110)
                    .edgesIgnoringSafeArea(.bottom)
                    .zIndex(0.5)
                    .offset(y: 40)
            }
            .frame(maxHeight: .infinity)

            VStack {
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
                .offset(y: -50)
                .zIndex(1)
            }

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
                ZStack {
                    HBSegmentedPicker(
                        selectedIndex: $selectedIndex,
                        items: SwipeContentType.allCases.map { $0.rawValue }
                    )
                    .frame(width: 260, height: 40)

                    HStack {
                        Spacer()
                        Menu {
                            switch selectedType {
                            case .movies:
                                ForEach(MovieCategory.allCases) { category in
                                    Button {
                                        movieVM.selectedCategory = category
                                        reloadSwipeItems()
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
                                        reloadSwipeItems()
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
                        .padding(.trailing, 30)
                    }
                }
                .frame(height: 160)
            }
            .zIndex(1)
        }
        .onAppear {
            movieVM.fetch()
            tvShowVM.fetch()
            reloadSwipeItems()
        }
        .onChange(of: movieVM.movies) { _ in
            if selectedType == .movies {
                reloadSwipeItems()
            }
        }
        .onChange(of: tvShowVM.shows) { _ in
            if selectedType == .tvShows {
                reloadSwipeItems()
            }
        }
        // MARK: - Denna onChange löser problemet med växlingen
        .onChange(of: selectedIndex) { _ in
            reloadSwipeItems()
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

    private func reloadSwipeItems() {
        switch selectedType {
        case .movies:
            swipeItems = interleavedItems(from: movieVM.movies, isMovie: true)
        case .tvShows:
            swipeItems = interleavedItems(from: tvShowVM.shows, isMovie: false)
        }
    }

    private func swipeCardStack() -> some View {
        return AnyView(
            swipeStack(items: swipeItems, onRemove: { liked, item in
                switch item {
                case .movie(let movie):
                    if liked { watchList.addMovie(movie); showToast(text: "Added to Watchlist") }
                case .tvShow(let show):
                    if liked { watchList.addTVShow(show); showToast(text: "Added to Watchlist") }
                case .ad:
                    break
                }
                swipeItems.removeFirst()
            }) { item in
                switch item {
                case .movie(let movie):
                    MovieCard(movie: movie) { selectedExpandedMovie = movie }
                case .tvShow(let show):
                    TVShowCard(show: show) { selectedExpandedTVShow = show }
                case .ad:
                    NativeContentView(navigationTitle: "Ad")
                }
            }
        )
    }

    private func interleavedItems<T: Identifiable>(from items: [T], adFrequency: Int = 3, isMovie: Bool) -> [SwipeCardItem] {
        var result: [SwipeCardItem] = []
        for (index, item) in items.enumerated() {
            if index > 0 && index % adFrequency == 0 && !AdsRemoved {
                result.append(.ad())
            }
            if isMovie, let movie = item as? Movie {
                result.append(.movie(movie))
            } else if let show = item as? TVShow {
                result.append(.tvShow(show))
            }
        }
        return result
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
                ForEach(Array(items.prefix(5).enumerated()), id: \ .1.id) { index, item in
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
}

#Preview {
    SwipeFlixIndex()
        .environmentObject(WatchListManager())
        .preferredColorScheme(.dark)
}
