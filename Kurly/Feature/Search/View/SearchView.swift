//
//  SearchView.swift
//  Kurly
//
//  Created by 김승율 on 3/30/26.
//

import ComposableArchitecture
import SwiftUI

struct SearchView: View {
    @Bindable var store: StoreOf<SearchStore>
    @FocusState private var isFocused: Bool
    @State private var isScrolledDown: Bool = false
    
    var body: some View {
        BaseView(store: store.scope(state: \.base, action: \.base), isShowNaviBar: false) {
            if !isFocused && !isScrolledDown {
                Text("Search")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            }
            
            SearchBarView(
                text: $store.data.searchText.sending(\.searchTextChanged),
                isFocused: $isFocused,
                onSubmit: { store.send(.submitSearch(store.data.searchText)) },
                onCancel: {
                    store.send(.searchTextChanged(""))
                    isFocused = false
                }
            )
            
            if store.data.isSearched {
                SearchResultListView(
                       totalCount: store.data.totalCount,
                       repositories: store.data.repositories,
                       hasMorePages: store.data.hasMorePages,
                       onSelect: { store.send(.selectRepository($0)) },
                       onLoadMore: { store.send(.loadNextPage) },
                       onScrollChanged: { offset in
                           isScrolledDown = offset > 0
                       }
                   )
            } else if !store.data.isSearching && !store.data.recentSearches.isEmpty {
                RecentSearchListView(
                    recentSearches: store.data.recentSearches,
                    onSelect: {
                        store.send(.submitSearch($0.keyword))
                        isFocused = false
                    },
                    onDelete: { store.send(.deleteRecentSearch($0)) },
                    onDeleteAll: { store.send(.deleteAllRecentSearches) }
                )
            } else if store.data.isSearching && !store.data.autoCompletions.isEmpty {
                AutoCompleteListView(
                    autoCompletions: store.data.autoCompletions,
                    onSelect: {
                        store.send(.submitSearch($0.keyword))
                        isFocused = false
                    }
                )
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    SearchView(
        store: Store(
            initialState: SearchStore.State()
        ) {
            SearchStore()
        }
    )
}
