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
    @Published var movieResultsOnly: [SearchResult] = []
    @Published var tvResultsOnly: [SearchResult] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""

    private let apiKey = "19deb7cbacfe2238a57278a1a57a43e6"

    func search(query: String) {
        guard !query.isEmpty else {
            movieResultsOnly = []
            tvResultsOnly = []
            return
        }

        isLoading = true
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let group = DispatchGroup()
        var movieResults: [Movie] = []
        var tvResults: [TVShow] = []

        group.enter()
        if let url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(encodedQuery)") {
            URLSession.shared.dataTask(with: url) { data, _, error in
                defer { group.leave() }
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(MovieResponse.self, from: data)
                        movieResults = response.results
                    } catch {
                        print("Movie decode error: \(error)")
                    }
                }
            }.resume()
        } else {
            group.leave()
        }

        group.enter()
        if let url = URL(string: "https://api.themoviedb.org/3/search/tv?api_key=\(apiKey)&query=\(encodedQuery)") {
            URLSession.shared.dataTask(with: url) { data, _, error in
                defer { group.leave() }
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(TVShowResponse.self, from: data)
                        tvResults = response.results
                    } catch {
                        print("TV decode error: \(error)")
                    }
                }
            }.resume()
        } else {
            group.leave()
        }

        group.notify(queue: .main) {
            self.movieResultsOnly = movieResults.map {
                SearchResult(
                    id: $0.id,
                    title: $0.title,
                    imageURL: $0.posterURLSmall,
                    year: $0.releaseYear,
                    rating: $0.voteAverage,
                    overview: $0.overview,
                    isMovie: true,
                    movie: $0,
                    tvShow: nil
                )
            }

            self.tvResultsOnly = tvResults.map {
                SearchResult(
                    id: $0.id + 1000000,
                    title: $0.name,
                    imageURL: $0.posterURLSmall,
                    year: $0.releaseYear,
                    rating: $0.voteAverage,
                    overview: $0.overview,
                    isMovie: false,
                    movie: nil,
                    tvShow: $0
                )
            }

            self.isLoading = false
        }
    }
}

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject private var watchList: WatchListManager
    @State private var selectedItem: SearchResult?

    var body: some View {
        VStack {
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

            if viewModel.isLoading {
                Spacer()
                ProgressView("Searching...")
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if !viewModel.movieResultsOnly.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Movies")
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(viewModel.movieResultsOnly) { result in
                                            CompactMovieCard(
                                                title: result.title,
                                                imageURL: result.imageURL,
                                                tapAction: {
                                                    selectedItem = result
                                                }
                                            )
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }

                        if !viewModel.tvResultsOnly.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("TV Shows")
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(viewModel.tvResultsOnly) { result in
                                            CompactMovieCard(
                                                title: result.title,
                                                imageURL: result.imageURL,
                                                tapAction: {
                                                    selectedItem = result
                                                }
                                            )
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }

                        if viewModel.movieResultsOnly.isEmpty &&
                            viewModel.tvResultsOnly.isEmpty &&
                            !viewModel.searchText.isEmpty {
                            Text("No results found")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedItem) { item in
            ExpandedCardView(
                title: item.title,
                overview: item.overview,
                imageURL: item.imageURL,
                onClose: { selectedItem = nil },
                isFavorite: Binding(
                    get: { watchList.contains(item) },
                    set: { newValue in
                        if newValue {
                            watchList.add(item)
                        } else {
                            watchList.remove(item)
                        }
                    }
                ),
                rating: item.rating,
                year: item.year,
                topGenre: item.movie?.genreNames.first ?? item.tvShow?.genreNames.first
            )
        }
    }
}
