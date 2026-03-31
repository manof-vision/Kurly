//
//  SearchModel.swift
//  Kurly
//
//  Created by 김승율 on 3/30/26.
//

import Foundation

struct SearchModel: Equatable {
    var searchText: String = ""
    var isSearching: Bool {
        !searchText.isEmpty
    }
    
    var recentSearches: [RecentSearchModel] = []
    var autoCompletions: [RecentSearchModel] = []
    
    var repositories: [Repository] = []
    var currentPage: Int = 1
    var totalCount: Int = 0
    var isSearched: Bool = false
    var hasMorePages: Bool = true
    var isLoadingMore: Bool = false
}
