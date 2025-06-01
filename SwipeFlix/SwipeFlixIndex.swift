import SwiftUI

enum SwipeContentType: String, CaseIterable, Identifiable {
    case movies = "Movies"
    case tvShows = "TV Shows"
    var id: String { rawValue }
}

enum SwipeDirection {
    case left, right
}

extension URL: Identifiable {
    public var id: String { absoluteString }
}

struct SwipeFlixIndex: View {
    @EnvironmentObject private var watchList: WatchListManager
    @AppStorage("AdsRemoved") private var AdsRemoved = false
    @StateObject private var storeManager = StoreManager()
    @StateObject private var movieVM = MovieViewModel()
    @StateObject private var tvShowVM = TVShowViewModel()
    @State private var selectedTab = 0
    @State private var selectedIndex = 0
    @State private var showToast = false
    @State private var toastText = ""
    @State private var selectedSearchURL: URL? = nil
    @State private var triggerSwipe = false
    @State private var swipeDirection: SwipeDirection? = nil

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
            NavigationView {
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
                        Button(action: {
                            swipeLeft()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                        }

                        Button(action: {
                            swipeRight()
                        }) {
                            Image(systemName: "heart.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                        }
                    }
                    .offset(y: UIScreen.main.bounds.height * 0.82)
                    .zIndex(1)

                    if showToast {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
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
                        HBSegmentedPicker(
                            selectedIndex: $selectedIndex,
                            items: SwipeContentType.allCases.map { $0.rawValue }
                        )
                        .frame(width: 260, height: 40)
                    }
                    .zIndex(1)
                }
                .onAppear {
                    movieVM.fetch()
                    tvShowVM.fetch()
                }
            }
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
        .background(Color.black.ignoresSafeArea(edges: .bottom))
    }

    private func swipeCardStack() -> some View {
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
                        if let url = googleSearchURL(for: movie.title) {
                            selectedSearchURL = url
                        }
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
                        if let url = googleSearchURL(for: show.title) {
                            selectedSearchURL = url
                        }
                    }
                }
            )
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

    private func googleSearchURL(for query: String) -> URL? {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://www.google.com/search?q=\(encoded)")
    }
}

#Preview {
    SwipeFlixIndex()
        .environmentObject(WatchListManager())
        .preferredColorScheme(.dark)
}
