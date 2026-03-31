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
}
