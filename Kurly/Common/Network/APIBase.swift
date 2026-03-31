//
//  APIBase.swift
//  Kurly
//
//  Created by 김승율 on 3/30/26.
//

import Foundation
import Moya

protocol CachePolicyConfigurable { var cachePolicy: URLRequest.CachePolicy { get } }
protocol TimeoutConfigurable { var timeout: TimeInterval { get } }
protocol BaseTargetType: TargetType, CachePolicyConfigurable, TimeoutConfigurable {}

extension BaseTargetType {
    var baseURL: URL {
        guard let url = URL(string: APIPath.baseURL) else {
            return URL(fileURLWithPath: "")
        }
        return url
    }

    var headers: [String: String]? {
        nil
    }

    var sampleData: Data {
        Data()
    }

    var validationType: ValidationType {
        .successCodes
    }

    var cachePolicy: URLRequest.CachePolicy {
        .useProtocolCachePolicy
    }

    var timeout: TimeInterval {
        30
    }
}

protocol APIEndpoint: BaseTargetType {
    associatedtype Response: Decodable
}
