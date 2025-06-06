import SwiftUI

struct SearchResult: Identifiable {
    let id: Int
    let title: String
    let imageURL: URL?
    let year: String?
    let rating: Double?
    let overview: String
    let isMovie: Bool
    let movie: Movie?
    let tvShow: TVShow?
}

class SearchViewModel: ObservableObject {
    @Published var searchResults: [SearchResult] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    
    private let apiKey = "19deb7cbacfe2238a57278a1a57a43e6"
    
    func search(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Search both movies and TV shows
        let group = DispatchGroup()
        var movieResults: [Movie] = []
        var tvResults: [TVShow] = []
        
        // Search movies
        group.enter()
        if let url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(encodedQuery)") {
            URLSession.shared.dataTask(with: url) { data, _, error in
                defer { group.leave() }
                
                if let error = error {
                    print("Movie search error: \(error)")
                    return
                }
                
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(MovieResponse.self, from: data)
                        movieResults = response.results
                        print("Found \(movieResults.count) movies")
                    } catch {
                        print("Movie decode error: \(error)")
                    }
                }
            }.resume()
        } else {
            group.leave()
        }
        
        // Search TV shows
        group.enter()
        if let url = URL(string: "https://api.themoviedb.org/3/search/tv?api_key=\(apiKey)&query=\(encodedQuery)") {
            URLSession.shared.dataTask(with: url) { data, _, error in
                defer { group.leave() }
                
                if let error = error {
                    print("TV search error: \(error)")
                    return
                }
                
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(TVShowResponse.self, from: data)
                        tvResults = response.results
                        print("Found \(tvResults.count) TV shows")
                    } catch {
                        print("TV decode error: \(error)")
                    }
                }
            }.resume()
        } else {
            group.leave()
        }
        
        // Combine results
        group.notify(queue: .main) {
            var combinedResults: [SearchResult] = []
            
            // Add movie results
            for movie in movieResults {
                let result = SearchResult(
                    id: movie.id,
                    title: movie.title,
                    imageURL: movie.posterURLSmall,
                    year: movie.releaseYear,
                    rating: movie.voteAverage,
                    overview: movie.overview,
                    isMovie: true,
                    movie: movie,
                    tvShow: nil
                )
                combinedResults.append(result)
            }
            
            // Add TV show results
            for tvShow in tvResults {
                let result = SearchResult(
                    id: tvShow.id + 1000000, // Offset to avoid ID conflicts
                    title: tvShow.name,
                    imageURL: tvShow.posterURLSmall,
                    year: tvShow.releaseYear,
                    rating: tvShow.voteAverage,
                    overview: tvShow.overview,
                    isMovie: false,
                    movie: nil,
                    tvShow: tvShow
                )
                combinedResults.append(result)
            }
            
            self.searchResults = combinedResults
            self.isLoading = false
            print("Total combined results: \(combinedResults.count)")
        }
    }
}

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject private var watchList: WatchListManager
    @State private var selectedItem: SearchResult?
    
    var body: some View {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search movies and TV shows...", text: $viewModel.searchText)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            viewModel.search(query: viewModel.searchText)
                        }
                    
                    if !viewModel.searchText.isEmpty {
                        Button("Search") {
                            viewModel.search(query: viewModel.searchText)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
                
                // Content area
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Searching...")
                    Spacer()
                } else if !viewModel.searchResults.isEmpty {
                    // Simple list of results
                    List(viewModel.searchResults) { result in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.title)
                                .font(.headline)
                            
                            Text(result.isMovie ? "Movie" : "TV Show")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if let year = result.year {
                                Text(year)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            print("Tapped: \(result.title)")
                            selectedItem = result
                        }
                    }
                } else {
                    // Empty space when no search or no results
                    Spacer()
                    if !viewModel.searchText.isEmpty {
                        Text("No results found")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedItem) { item in
            // Simple detail view
            NavigationView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(item.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(item.isMovie ? "Movie" : "TV Show")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    if let year = item.year {
                        Text("Year: \(year)")
                            .font(.subheadline)
                    }
                    
                    if let rating = item.rating {
                        Text("Rating: \(String(format: "%.1f", rating))")
                            .font(.subheadline)
                    }
                    
                    if !item.overview.isEmpty {
                        Text("Overview:")
                            .font(.headline)
                        
                        Text(item.overview)
                            .font(.body)
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            selectedItem = nil
                        }
                    }
                }
            }
        }
    }
}
