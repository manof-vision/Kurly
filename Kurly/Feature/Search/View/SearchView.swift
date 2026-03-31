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
    
    var body: some View {
        BaseView(store: store.scope(state: \.base, action: \.base), isShowNaviBar: false) {
            if !isFocused {
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
            
            if !store.data.isSearching && !store.data.recentSearches.isEmpty {
                RecentSearchListView(
                    recentSearches: store.data.recentSearches,
                    onSelect: { store.send(.selectRecentSearch($0)) },
                    onDelete: { store.send(.deleteRecentSearch($0)) },
                    onDeleteAll: { store.send(.deleteAllRecentSearches) }
                )
            } else if store.data.isSearching && !store.data.autoCompletions.isEmpty {
                AutoCompleteListView(
                    autoCompletions: store.data.autoCompletions,
                    onSelect: { store.send(.submitSearch($0.keyword)) }
                )
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}
