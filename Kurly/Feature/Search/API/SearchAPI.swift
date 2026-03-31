//
//  SearchAPI.swift
//  Kurly
//
//  Created by 김승율 on 3/30/26.
//

import Moya
import Alamofire

struct SearchAPI: APIEndpoint {
    typealias Response = SearchResponse
    
    var keyword: String
    var page: Int
    
    var path: String { APIPath.search }
    var method: Moya.Method { .get }
    var task: Task {
        .requestParameters(
            parameters: [
                "q": keyword,
                "page": page
            ],
            encoding: URLEncoding.queryString
        )
    }
}
