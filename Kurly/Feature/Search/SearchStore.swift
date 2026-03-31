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
        case selectRecentSearch(RecentSearchModel)
        case deleteRecentSearch(RecentSearchModel)
        case deleteAllRecentSearches

    }
    
    @Dependency(\.recentSearchClient) var recentSearchClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.data.recentSearches = recentSearchClient.load()
                return .none
                
            case let .searchTextChanged(text):
                state.data.searchText = text
                if text.isEmpty {
                    state.data.autoCompletions = []
                } else {
                    state.data.autoCompletions = state.data.recentSearches.filter {
                        $0.keyword.localizedCaseInsensitiveContains(text)
                    }
                }

                return .none
                
            case let .submitSearch(keyword):
                guard !keyword.trimmingCharacters(in: .whitespaces).isEmpty else { return .none }
                recentSearchClient.save(keyword)
                state.data.recentSearches = recentSearchClient.load()
                return .none
                
            case let .selectRecentSearch(search):
                return .send(.submitSearch(search.keyword))
                
            case let .deleteRecentSearch(search):
                recentSearchClient.delete(search)
                state.data.recentSearches = recentSearchClient.load()
                return .none
                
            case .deleteAllRecentSearches:
                recentSearchClient.deleteAll()
                state.data.recentSearches = []
                return .none
                
            default:
                return .none
            }
        }
        Scope(state: \.base, action: \.base) { BaseStore() }
    }
}
