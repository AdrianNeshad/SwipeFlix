//
//  NewsIndex.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-01.
//

import SwiftUI
import AlertToast

struct NewsIndex: View {
    @AppStorage("AdsRemoved") private var AdsRemoved = false
    @StateObject private var storeManager = StoreManager()
    @StateObject var viewModel = NewsViewModel()
    @State private var showingSheet = false
    @State private var selectedLink: IdentifiableURL? = nil
    @State private var showingCategoryPicker = false
    @State private var showFeedUpdatedToast = false
    @State private var wasLoading = false

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    if viewModel.isLoading {
                        VStack(spacing: 8) {
                            ProgressView()
                                .padding(.top, 20)
                                .scaleEffect(1.75)
                            Text("Loading Feed...")
                                .font(.body)
                                .padding(.top, 20)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                    else {
                        ForEach(Array(viewModel.newsItems.enumerated()), id: \.element.id) { index, item in
                            NewsItemView(newsItem: item)
                                .padding(.horizontal)
                                .onTapGesture {
                                    if let link = item.link {
                                        selectedLink = IdentifiableURL(url: link)
                                    }
                                }
                        }
                    }
                }
            }
            .sheet(item: $selectedLink) { wrapped in
                SafariView(url: wrapped.url)
            }
            .refreshable {
                viewModel.loadNews()
            }
            .navigationTitle("News Feed")
            .onChange(of: viewModel.isLoading) { isLoading in
                if wasLoading && !isLoading {
                    showFeedUpdatedToast = true
                }
                wasLoading = isLoading
            }
            .toast(isPresenting: $showFeedUpdatedToast, duration: 1.5) {
                AlertToast(displayMode: .hud,
                           type: .complete(.green),
                           title: "Updated",
                           subTitle: "Showing Latest")
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

            NewsIndex()
                .tabItem {
                    Label("News Feed", systemImage: "newspaper")
                }
                .tag(2)
            
            Settings()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
    }
}

struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}
