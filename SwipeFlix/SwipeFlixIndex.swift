//
//  SwipeFlixIndex.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-05-31.
//

import SwiftUI

enum SwipeContentType: String, CaseIterable, Identifiable {
    case movies = "Movies"
    case tvShows = "TV Shows"
    var id: String { rawValue }
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
                            switch selectedType {
                            case .movies:
                                swipeStack(items: movieVM.movies, onRemove: { liked, movie in
                                    if liked {
                                        watchList.addMovie(movie)
                                        showToast(text: "Added to Watchlist")
                                    }
                                    movieVM.removeTop()
                                }) { movie in
                                    MovieCard(movie: movie)
                                }

                            case .tvShows:
                                swipeStack(items: tvShowVM.shows, onRemove: { liked, show in
                                    if liked {
                                        watchList.addTVShow(show)
                                        showToast(text: "Added to Watchlist")
                                    }
                                    tvShowVM.removeTop()
                                }) { show in
                                    TVShowCard(show: show)
                                }
                            }
                        }
                        .frame(height: UIScreen.main.bounds.height * 0.75)
                        .padding(.bottom, 40)
                        .zIndex(0)
                    }

                    VStack {
                        Rectangle() // Top
                            .fill(Color.black)
                            .frame(height: 160)
                            .edgesIgnoringSafeArea(.top)
                            .zIndex(0.5)
                        Spacer()
                        Rectangle() // Bottom
                            .fill(Color.black)
                            .frame(height: 70)
                            .edgesIgnoringSafeArea(.bottom)
                            .zIndex(0.5)
                    }
                    if showToast {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                                .imageScale(.large)

                            Text(toastText)
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(Color.black.opacity(0.9))
                        .cornerRadius(12)
                        .padding(.top, 100)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(2)
                    }
                    VStack(spacing: 20) {
                        Text("SwipeFlix")
                            .font(.largeTitle.bold())
                            .padding(.top, 50)
                        HBSegmentedPicker(
                            selectedIndex: $selectedIndex,
                            items: SwipeContentType.allCases.map { $0.rawValue }
                        )
                        .frame(width: 300, height: 40)
                        .padding(.horizontal)
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
                    Label("Watch List", systemImage: "list.bullet.rectangle")
                }
                .tag(1)

            Settings()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .background(Color.black.ignoresSafeArea(edges: .bottom))
    }

    private func swipeStack<T: Identifiable, Content: View>(
        items: [T],
        onRemove: @escaping (Bool, T) -> Void,
        @ViewBuilder content: @escaping (T) -> Content
    ) -> some View {
        ZStack {
            if items.isEmpty {
                Text("No more items!")
                    .font(.title)
                    .foregroundColor(.gray)
            } else {
                ForEach(Array(items.prefix(5).enumerated()), id: \.1.id) { index, item in
                    SwipeCard(
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

#Preview {
    SwipeFlixIndex()
        .environmentObject(WatchListManager())
        .preferredColorScheme(.dark)
}
