//
//  SearchResponse.swift
//  Kurly
//
//  Created by 김승율 on 3/30/26.
//

import Foundation

struct SearchResponse: Codable, Equatable {
    let totalCount: Int
    let items: [Repository]
    
    init(totalCount: Int = 0,
         items: [Repository] = []) {
        self.totalCount = totalCount
        self.items = items
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalCount = try container.decodeIfPresent(Int.self, forKey: .totalCount) ?? 0
        items = try container.decodeIfPresent([Repository].self, forKey: .items) ?? []
    }

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}

struct Repository: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
    let htmlUrl: String
    let owner: Owner
    
    init(id: Int,
         name: String = "",
         htmlUrl: String = "",
         owner: Owner = Owner()) {
        self.id = id
        self.name = name
        self.htmlUrl = htmlUrl
        self.owner = owner
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        htmlUrl = try container.decodeIfPresent(String.self, forKey: .htmlUrl) ?? ""
        owner = try container.decodeIfPresent(Owner.self, forKey: .owner) ?? Owner()
    }

    enum CodingKeys: String, CodingKey {
        case id, name, owner
        case htmlUrl = "html_url"
    }
}

struct Owner: Codable, Equatable {
    let login: String
    let avatarUrl: String
    
    init(login: String = "",
         avatarUrl: String = "") {
        self.login = login
        self.avatarUrl = avatarUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        login = try container.decodeIfPresent(String.self, forKey: .login) ?? ""
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl) ?? ""
    }

    enum CodingKeys: String, CodingKey {
        case login
        case avatarUrl = "avatar_url"
    }
}
