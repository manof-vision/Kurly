//
//  RecentSearchModel.swift
//  Kurly
//
//  Created by 김승율 on 3/31/26.
//

import Foundation
import ComposableArchitecture

struct RecentSearchModel: Equatable, Codable {
    var keyword: String = ""
    var date: Date = Date()
}

struct RecentSearchClient {
    var load: () -> [RecentSearchModel]
    var save: (String) -> Void
    var delete: (RecentSearchModel) -> Void
    var deleteAll: () -> Void
}

extension RecentSearchClient: DependencyKey {
    private static let key = "recent_searches"
    private static let maxCount = 10

    static let liveValue = RecentSearchClient(
        load: {
            guard let data = UserDefaults.standard.data(forKey: key),
                  let searches = try? JSONDecoder().decode([RecentSearchModel].self, from: data) else {
                return []
            }
            return searches.sorted { $0.date > $1.date }
        },
        save: { keyword in
            var searches = (try? JSONDecoder().decode([RecentSearchModel].self, from: UserDefaults.standard.data(forKey: key) ?? Data())) ?? []

            searches.removeAll { $0.keyword == keyword }
            searches.insert(RecentSearchModel(keyword: keyword), at: 0)

            if searches.count > maxCount {
                searches = Array(searches.prefix(maxCount))
            }

            if let data = try? JSONEncoder().encode(searches) {
                UserDefaults.standard.set(data, forKey: key)
            }
        },
        delete: { search in
            var searches = (try? JSONDecoder().decode([RecentSearchModel].self, from: UserDefaults.standard.data(forKey: key) ?? Data())) ?? []

            searches.removeAll { $0.keyword == search.keyword }

            if let data = try? JSONEncoder().encode(searches) {
                UserDefaults.standard.set(data, forKey: key)
            }
        },
        deleteAll: {
            UserDefaults.standard.removeObject(forKey: key)
        }
    )
}

extension DependencyValues {
    var recentSearchClient: RecentSearchClient {
        get { self[RecentSearchClient.self] }
        set { self[RecentSearchClient.self] = newValue }
    }
}
