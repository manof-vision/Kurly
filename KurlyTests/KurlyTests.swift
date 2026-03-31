//
//  KurlyTests.swift
//  KurlyTests
//
//  Created by 김승율 on 3/28/26.
//

import Foundation
import ComposableArchitecture
import Testing
import Moya
@testable import Kurly

@MainActor
struct SearchStoreTests {
    private let mockRecentSearches: [RecentSearchModel] = MockLoader.load("MockRecentSearches")
    private let mockResponse: SearchResponse = MockLoader.load("MockSearchResponse")
    private let emptyResponse: SearchResponse = MockLoader.load("MockEmptySearchResponse")

    private func makeStore(recentSearches: [RecentSearchModel]? = nil) -> TestStore<SearchStore.State, SearchStore.Action> {
        var saved = recentSearches ?? mockRecentSearches

        return TestStore(initialState: SearchStore.State()) {
            SearchStore()
        } withDependencies: {
            $0.recentSearchClient = RecentSearchClient(
                load: { saved.sorted { $0.date > $1.date } },
                save: { keyword in
                    saved.removeAll { $0.keyword == keyword }
                    saved.insert(RecentSearchModel(keyword: keyword), at: 0)
                },
                delete: { search in
                    saved.removeAll { $0.keyword == search.keyword }
                },
                deleteAll: { saved = [] }
            )
            $0.apiClient = APIClient(
                request: { _ in fatalError("Should not be called") }
            )
        }
    }

    // MARK: - onAppear

    @Test func onAppear_loadsRecentSearches() async {
        let store = makeStore()

        await store.send(.onAppear) {
            $0.data.recentSearches = self.mockRecentSearches.sorted { $0.date > $1.date }
        }
    }

    // MARK: - searchTextChanged

    @Test func searchTextChanged_updatesTextAndFiltersAutoComplete() async {
        let store = makeStore()

        await store.send(.onAppear) {
            $0.data.recentSearches = self.mockRecentSearches.sorted { $0.date > $1.date }
        }

        await store.send(.searchTextChanged("Swift")) {
            $0.data.searchText = "Swift"
            $0.data.isSearched = false
            $0.data.repositories = []
            $0.data.totalCount = 0
            $0.data.autoCompletions = self.mockRecentSearches.sorted { $0.date > $1.date }
        }
    }

    @Test func searchTextChanged_emptyTextClearsAutoComplete() async {
        let store = makeStore()

        await store.send(.onAppear) {
            $0.data.recentSearches = self.mockRecentSearches.sorted { $0.date > $1.date }
        }

        await store.send(.searchTextChanged("Swift")) {
            $0.data.searchText = "Swift"
            $0.data.isSearched = false
            $0.data.repositories = []
            $0.data.totalCount = 0
            $0.data.autoCompletions = self.mockRecentSearches.sorted { $0.date > $1.date }
        }

        await store.send(.searchTextChanged("")) {
            $0.data.searchText = ""
            $0.data.autoCompletions = []
        }
    }

    // MARK: - submitSearch

    @Test func submitSearch_emptyKeywordDoesNothing() async {
        let store = makeStore()

        await store.send(.submitSearch("   ")) {
            $0.data.searchText = "   "
        }
    }

    @Test func submitSearch_savesAndFetchesResults() async {
        let response = mockResponse
        let fixedDate = Date(timeIntervalSince1970: 0)
        var saved: [RecentSearchModel] = []

        let store = TestStore(initialState: SearchStore.State()) {
            SearchStore()
        } withDependencies: {
            $0.recentSearchClient = RecentSearchClient(
                load: { saved },
                save: { keyword in saved.append(RecentSearchModel(keyword: keyword, date: fixedDate)) },
                delete: { _ in },
                deleteAll: { }
            )
            $0.apiClient = APIClient(
                request: { _ in
                    let data = try! JSONEncoder().encode(response)
                    return .init(statusCode: 200, data: data)
                }
            )
        }

        await store.send(.submitSearch("swift")) {
            $0.data.searchText = "swift"
            $0.data.recentSearches = [RecentSearchModel(keyword: "swift", date: fixedDate)]
            $0.data.currentPage = 1
        }

        await store.receive(.base(.fromFeature(.showLoadingView(true)))) {
            $0.base.isLoading = true
        }

        await store.receive(.searchResponse(response)) {
            $0.data.totalCount = 100
            $0.data.repositories = response.items
            $0.data.hasMorePages = true
            $0.data.isSearched = true
        }

        await store.receive(.base(.fromFeature(.showLoadingView(false)))) {
            $0.base.isLoading = false
        }
    }

    // MARK: - deleteRecentSearch

    @Test func deleteRecentSearch_removesFromList() async {
        let store = makeStore()
        let searchToDelete = mockRecentSearches[0]

        await store.send(.onAppear) {
            $0.data.recentSearches = self.mockRecentSearches.sorted { $0.date > $1.date }
        }

        await store.send(.deleteRecentSearch(searchToDelete)) {
            $0.data.recentSearches = [self.mockRecentSearches[1]]
        }
    }

    // MARK: - deleteAllRecentSearches

    @Test func deleteAllRecentSearches_clearsAll() async {
        let store = makeStore()

        await store.send(.onAppear) {
            $0.data.recentSearches = self.mockRecentSearches.sorted { $0.date > $1.date }
        }

        await store.send(.deleteAllRecentSearches) {
            $0.data.recentSearches = []
        }
    }

    // MARK: - searchResponse

    @Test func searchResponse_updatesState() async {
        let store = makeStore()

        await store.send(.searchResponse(mockResponse)) {
            $0.data.totalCount = 100
            $0.data.repositories = self.mockResponse.items
            $0.data.hasMorePages = true
            $0.data.isSearched = true
        }
    }

    @Test func searchResponse_emptyItemsSetsNoMorePages() async {
        let store = makeStore()

        await store.send(.searchResponse(emptyResponse)) {
            $0.data.totalCount = 100
            $0.data.repositories = []
            $0.data.hasMorePages = false
            $0.data.isSearched = true
        }
    }

    // MARK: - loadNextPage

    @Test func loadNextPage_whenAlreadyLoading_doesNothing() async {
        var state = SearchStore.State()
        state.data.isLoadingMore = true

        let store = TestStore(initialState: state) {
            SearchStore()
        } withDependencies: {
            $0.recentSearchClient = RecentSearchClient(load: { [] }, save: { _ in }, delete: { _ in }, deleteAll: { })
            $0.apiClient = APIClient(request: { _ in fatalError() })
        }

        await store.send(.loadNextPage)
    }

    @Test func loadNextPage_whenNoMorePages_doesNothing() async {
        var state = SearchStore.State()
        state.data.hasMorePages = false

        let store = TestStore(initialState: state) {
            SearchStore()
        } withDependencies: {
            $0.recentSearchClient = RecentSearchClient(load: { [] }, save: { _ in }, delete: { _ in }, deleteAll: { })
            $0.apiClient = APIClient(request: { _ in fatalError() })
        }

        await store.send(.loadNextPage)
    }

    // MARK: - nextPageResponse

    @Test func nextPageResponse_appendsItems() async {
        var state = SearchStore.State()
        state.data.repositories = mockResponse.items
        state.data.isLoadingMore = true
        state.data.currentPage = 1

        let store = TestStore(initialState: state) {
            SearchStore()
        } withDependencies: {
            $0.recentSearchClient = RecentSearchClient(load: { [] }, save: { _ in }, delete: { _ in }, deleteAll: { })
            $0.apiClient = APIClient(request: { _ in fatalError() })
        }

        let newItems = [Repository(id: 3, name: "new-repo", owner: Owner(login: "user"))]
        let nextResponse = SearchResponse(totalCount: 100, items: newItems)

        await store.send(.nextPageResponse(nextResponse)) {
            $0.data.currentPage = 2
            $0.data.repositories = self.mockResponse.items + newItems
            $0.data.hasMorePages = true
            $0.data.isLoadingMore = false
        }
    }

    @Test func nextPageResponse_nilKeepsState() async {
        var state = SearchStore.State()
        state.data.isLoadingMore = true
        state.data.currentPage = 1

        let store = TestStore(initialState: state) {
            SearchStore()
        } withDependencies: {
            $0.recentSearchClient = RecentSearchClient(load: { [] }, save: { _ in }, delete: { _ in }, deleteAll: { })
            $0.apiClient = APIClient(request: { _ in fatalError() })
        }

        await store.send(.nextPageResponse(nil)) {
            $0.data.isLoadingMore = false
        }
    }

    // MARK: - selectRepository

    @Test func selectRepository_navigatesToWebView() async {
        let store = makeStore()
        let repo = Repository(id: 1, name: "swift", htmlUrl: "https://github.com/apple/swift", owner: Owner(login: "apple"))

        await store.send(.selectRepository(repo))

        await store.receive(.base(.toNavigation(.push(.webView(WebViewStore.State(url: "https://github.com/apple/swift"))))))
    }
}
