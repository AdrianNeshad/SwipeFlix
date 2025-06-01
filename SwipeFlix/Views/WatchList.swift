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
    @State private var selectedIndex = 0

    private var selectedSegment: WatchListSegment {
        get { WatchListSegment.allCases[selectedIndex] }
        set {
            if let index = WatchListSegment.allCases.firstIndex(of: newValue) {
                selectedIndex = index
            }
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            HBSegmentedPicker(
                selectedIndex: $selectedIndex,
                items: WatchListSegment.allCases.map { $0.rawValue }
            )
            .frame(width: 300, height: 44)
            .padding(.top, 30)

            ScrollView {
                VStack(spacing: 20) {
                    if selectedSegment == .movies {
                        if watchList.savedMovies.isEmpty {
                            Text("No saved movies yet.")
                                .foregroundColor(.gray)
                                .padding(.top, 50)
                        } else {
                            ForEach(watchList.savedMovies) { movie in
                                MovieCard(movie: movie)
                                    .padding(.horizontal)
                            }
                        }
                    } else if selectedSegment == .tvShows {
                        if watchList.savedTVShows.isEmpty {
                            Text("No saved TV shows yet.")
                                .foregroundColor(.gray)
                                .padding(.top, 50)
                        } else {
                            ForEach(watchList.savedTVShows) { show in
                                TVShowCard(show: show)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.top, 10)
            }
        }
        .padding(.bottom, 20)
        .background(Color.black.ignoresSafeArea())
    }
}
