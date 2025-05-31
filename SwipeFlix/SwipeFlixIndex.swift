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
    @AppStorage("AdsRemoved") private var AdsRemoved = false
    @StateObject private var storeManager = StoreManager()
    @StateObject private var movieVM = MovieViewModel()
    @StateObject private var tvShowVM = TVShowViewModel()
    @State private var selectedType: SwipeContentType = .movies
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                ZStack(alignment: .top) {
                    VStack {
                        Spacer(minLength: 150) // 🛡 Lämnar utrymme för titeln & picker
                        ZStack {
                            switch selectedType {
                            case .movies:
                                swipeStack(items: movieVM.movies, onRemove: { liked in
                                    movieVM.removeTop()
                                }) { movie in
                                    MovieCard(movie: movie)
                                }

                            case .tvShows:
                                swipeStack(items: tvShowVM.shows, onRemove: { liked in
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
                    VStack(spacing: 20) {
                        Text("SwipeFlix")
                            .font(.largeTitle.bold())
                            .padding(.top, 50)

                        Picker("Content Type", selection: $selectedType) {
                            ForEach(SwipeContentType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                    }
                    .zIndex(1) // 🔼 alltid framför korten
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
        onRemove: @escaping (Bool) -> Void,
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
                        onRemove: onRemove
                    )
                    .zIndex(Double(-index)) // säkerställer djup bakifrån
                    .padding(8)
                }
            }
        }
    }
}

#Preview {
    SwipeFlixIndex()
        .preferredColorScheme(.dark)
}
