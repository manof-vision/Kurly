//
//  APIPlugin.swift
//  Kurly
//
//  Created by 김승율 on 3/30/26.
//

import Foundation
import Moya

struct APIPlugin: PluginType {
    func prepare(_ request: URLRequest, target: any TargetType) -> URLRequest {
        var originalRequest = request

        if let cachePolicyConfigurable = target as? CachePolicyConfigurable {
            originalRequest.cachePolicy = cachePolicyConfigurable.cachePolicy
        }

        if let timeoutConfigurable = target as? TimeoutConfigurable {
            originalRequest.timeoutInterval = timeoutConfigurable.timeout
        }

        return originalRequest
    }

    func willSend(_ request: RequestType, target: TargetType) {
        guard let httpRequest = request.request else {
            Log.debug("[HTTP Request] 잘못된 요청")
            return
        }

        let url = httpRequest.description
        let method = httpRequest.httpMethod ?? "알 수 없는 Method"

        var httpLog = """
        \n[HTTP Request Start]===================================
        URL: \(url)
        TARGET: \(target)
        METHOD: \(method)\n
        """

        httpLog.append("HEADER: [\n")
        httpRequest.allHTTPHeaderFields?.forEach {
            httpLog.append("\t\($0): \($1)\n")
        }
        httpLog.append("]\n")

        if let body = httpRequest.httpBody, let bodyString = String(bytes: body, encoding: String.Encoding.utf8) {
            httpLog.append("BODY: \n\(bodyString)\n")
        }
        httpLog.append("[HTTP Request End]===================================")

        Log.debug(httpLog)
    }

    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case let .success(response):
            getResponseLog(response, target: target)
        case let .failure(error):
            if let response = error.response {
                getResponseLog(response, target: target, isError: true)
                return
            }

            var httpLog = """
                            \n[HTTP Error Start]===================================
            TARGET: \(target)
            ERRORCODE: \(error.errorCode)\n
            """
            httpLog.append("MESSAGE: \(error.failureReason ?? error.errorDescription ?? "unknown error")\n")
            httpLog.append("[HTTP Error End]===================================")

            Log.error(httpLog)
        }
    }

    func getResponseLog(_ response: Response, target: TargetType, isError: Bool = false) {
        let request = response.request
        let url = request?.url?.absoluteString ?? "알 수 없는 URL"
        let statusCode = response.statusCode

        var httpLog = """
        \n[HTTP Response Start]===================================
        URL: \(url)
        TARGET: \(target)
        STATUS CODE: \(statusCode)\n
        """

        httpLog.append("RESPONSE DATA: \n")
        if let responseString = String(bytes: response.data.toPrettyJSON(), encoding: String.Encoding.utf8) {
            httpLog.append("\(responseString)\n")
        }
        httpLog.append("[HTTP Response End]===================================")

        if isError {
            Log.error(httpLog)
        } else {
            Log.debug(httpLog)
        }
    }
}
