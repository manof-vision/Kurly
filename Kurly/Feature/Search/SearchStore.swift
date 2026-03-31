//
//  SearchStore.swift
//  Kurly
//
//  Created by 김승율 on 3/30/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SearchStore {
    @ObservableState
    struct State: Equatable {
        var base: BaseStore.State = .init()
        var data: SearchModel = .init()
    }

    enum Action: Equatable {
        case base(BaseStore.Action)
        case onAppear
        case searchTextChanged(String)
        case submitSearch(String)
        case deleteRecentSearch(RecentSearchModel)
        case deleteAllRecentSearches
        case searchResponse(SearchResponse)
        case loadNextPage
        case nextPageResponse(SearchResponse?)
        case selectRepository(Repository)
    }
    
    @Dependency(\.recentSearchClient) var recentSearchClient
    @Dependency(\.apiClient) var apiClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.data.recentSearches = recentSearchClient.load()
                return .none
                
            case let .searchTextChanged(text):
                state.data.searchText = text
                state.data.isSearched = false
                state.data.repositories = []
                state.data.totalCount = 0
                
                if text.isEmpty {
                    state.data.autoCompletions = []
                } else {
                    state.data.autoCompletions = state.data.recentSearches.filter {
                        $0.keyword.localizedCaseInsensitiveContains(text)
                    }
                }
                return .none
                
            case let .submitSearch(keyword):
                state.data.searchText = keyword
                guard !keyword.trimmingCharacters(in: .whitespaces).isEmpty else { return .none }
                recentSearchClient.save(keyword)
                state.data.recentSearches = recentSearchClient.load()
                state.data.currentPage = 1
                return .run { @MainActor send in
                    send(.base(.fromFeature(.showLoadingView(true))))
                    defer { send(.base(.fromFeature(.showLoadingView(false)))) }

                    do {
                        let response = try await apiClient.fetch(SearchAPI(keyword: keyword, page: 1))
                        send(.searchResponse(response))
                    } catch {
                        send(.base(.fromFeature(.showAlertView(StringConstant.repositoryLoadFail))))
                    }
                }
                
            case let .deleteRecentSearch(search):
                recentSearchClient.delete(search)
                state.data.recentSearches = recentSearchClient.load()
                return .none
                
            case .deleteAllRecentSearches:
                recentSearchClient.deleteAll()
                state.data.recentSearches = []
                return .none
                
            case let .searchResponse(response):
                state.data.totalCount = response.totalCount
                state.data.repositories = response.items
                state.data.hasMorePages = !response.items.isEmpty
                state.data.isSearched = true
                return .none
                
            case .loadNextPage:
                guard !state.data.isLoadingMore, state.data.hasMorePages else { return .none }

                state.data.isLoadingMore = true
                let keyword = state.data.searchText
                let nextPage = state.data.currentPage + 1

                return .run { @MainActor send in
                    do {
                        let response = try await apiClient.fetch(SearchAPI(keyword: keyword, page: nextPage))
                        send(.nextPageResponse(response))
                    } catch {
                        send(.base(.fromFeature(.showAlertView(StringConstant.repositoryLoadFail))))
                        send(.nextPageResponse(nil))
                    }
                }
                
            case let .nextPageResponse(response):
                if let response = response {
                    state.data.currentPage += 1
                    state.data.repositories += response.items
                    state.data.hasMorePages = !response.items.isEmpty
                }
                state.data.isLoadingMore = false
                return .none
                
            case let .selectRepository(repository):
                return .send(.base(.toNavigation(.push(.webView(WebViewStore.State(url: repository.htmlUrl))))))
                
            default:
                return .none
            }
        }
        Scope(state: \.base, action: \.base) { BaseStore() }
    }
}
