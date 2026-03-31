//
//  APIClient.swift
//  Kurly
//
//  Created by 김승율 on 3/30/26.
//

import Foundation
import Moya
import ComposableArchitecture

struct APIClient {
    var request: (_ target: MultiTarget) async throws -> Moya.Response
}

extension APIClient: DependencyKey {
    static let liveValue = APIClient(
        request: { target in
            let provider = MoyaProvider<MultiTarget>(plugins: [APIPlugin()])
            return try await withCheckedThrowingContinuation { continuation in
                provider.request(target) { result in
                    switch result {
                    case let .success(response):
                        continuation.resume(returning: response)
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    )
    
    static let testValue: Self = makeStubValue()
    static let previewValue: Self = makeStubValue()
    
    private static func makeStubValue() -> Self {
        let provider = MoyaProvider<MultiTarget>(stubClosure: MoyaProvider.immediatelyStub, plugins: [APIPlugin()])

        return .init(
            request: { target in
                try await withCheckedThrowingContinuation { continuation in
                    provider.request(target) { result in
                        switch result {
                        case let .success(response):
                            continuation.resume(returning: response)
                        case let .failure(error):
                            continuation.resume(throwing: error)
                        }
                    }
                }
            }
        )
    }
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}

extension APIClient {
    func fetch<E: APIEndpoint>(_ endpoint: E) async throws -> E.Response {
        let response = try await request(MultiTarget(endpoint))
        let filtered = try response.filterSuccessfulStatusCodes()
        return try JSONDecoder().decode(E.Response.self, from: filtered.data)
    }
}
