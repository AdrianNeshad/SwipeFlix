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
                            
                            // Byt  if AdsRemoved && (index + 1) % 4 == 0 {
                            // till if !AdsRemoved && (index + 1) % 4 == 0 {
                            // när reklam funkar
                            
                            
                            // Test banner id: ca-app-pub-3940256099942544/9214589741
                            
                            // Riktigt ID: ca-app-pub-9539709997316775/5936126417
                            if AdsRemoved && (index + 1) % 4 == 0 {
                                BannerAdView(adUnitID: "ca-app-pub-9539709997316775/5936126417")
                                    .frame(height: 150)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
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
        }
    }
}

struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}
