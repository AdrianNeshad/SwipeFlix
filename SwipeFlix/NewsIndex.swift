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
        NavigationStack {
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
            BannerAdView(adUnitID: "ca-app-pub-9539709997316775/5936126417")
                .frame(width: 320, height: 50)
                .padding(.bottom, 10)
                .padding(.top, 1)
            
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
        }
    }
}

struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}
