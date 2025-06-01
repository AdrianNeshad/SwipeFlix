//
//  NewsViewModel.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-01.
//

import Foundation
import Combine
import SwiftUI

class NewsViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var newsItems: [NewsItem] = []

    @Published var currentCategory: Category = .movie {
        didSet {
            loadActiveSources()
            loadNews()
        }
    }

    @Published var activeSources: Set<String> = [] {
        didSet {
            saveActiveSources()
        }
    }

    private var categoryKey: String {
        "activeSources_\(currentCategory.rawValue)"
    }

    var filteredSources: [NewsSource] {
        currentCategory.sources.filter { activeSources.isEmpty || activeSources.contains($0.name) }
    }

    init() {
        loadActiveSources()
        loadNews()
    }

    func loadActiveSources() {
        let saved = UserDefaults.standard.string(forKey: categoryKey)?
            .split(separator: "|")
            .map(String.init) ?? []

        let allNames = currentCategory.sources.map { $0.name }
        let validSaved = saved.filter { allNames.contains($0) }

        if !validSaved.isEmpty {
            activeSources = Set(validSaved)
        } else {
            if currentCategory == .movie {
                let defaultSources = currentCategory.sources.prefix(0).map { $0.name }
                activeSources = Set(defaultSources)
            } else {
                activeSources = Set(allNames)
            }
        }
    }

    func saveActiveSources() {
        let joined = activeSources.joined(separator: "|")
        UserDefaults.standard.setValue(joined, forKey: categoryKey)
    }

    func loadNews() {
        isLoading = true
        newsItems = []
        let group = DispatchGroup()
        var allItems: [NewsItem] = []
        var errors: [Error] = []

        let sources = filteredSources

        for source in sources {
            guard let feedURL = feedURL(for: source.name) else { continue }

            let rssFetcher = RSSFetcher()
            group.enter()
            rssFetcher.fetchFeed(from: feedURL, source: source) { result in
                switch result {
                case .success(let items):
                    allItems.append(contentsOf: items)
                case .failure(let error):
                    errors.append(error)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            var seen = Set<String>()
            let uniqueItems = allItems.filter { item in
                let key = "\(item.title)-\(item.pubDate?.timeIntervalSince1970 ?? 0)"
                if seen.contains(key) {
                    return false
                } else {
                    seen.insert(key)
                    return true
                }
            }
            self.newsItems = uniqueItems.sorted(by: { ($0.pubDate ?? Date.distantPast) > ($1.pubDate ?? Date.distantPast) })
            self.isLoading = false

            if !errors.isEmpty {
                print("Fel vid hämtning: \(errors)")
            }
        }
    }

    func feedURL(for sourceName: String) -> URL? {
        switch sourceName {
        case "FirstShowing":
            return URL(string: "https://www.firstshowing.net/feed/")
        case "Slashfilm":
            return URL(string: "https://www.slashfilm.com/feed/")
        case "Collider":
            return URL(string: "https://collider.com/feed/")
        case "The Wrap":
            return URL(string: "https://www.thewrap.com/category/movies/feed/")
        default:
            return nil
        }
    }
}
    