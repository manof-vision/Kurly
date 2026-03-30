//
//  DataExtension.swift
//  Kurly
//
//  Created by 김승율 on 3/30/26.
//

import Foundation

extension Data {
    func toPrettyJSON() -> Data {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: [])
            return try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        } catch {
            Log.error("PrettyJSON 파싱 오류: \(error.localizedDescription)")
            return Data()
        }
    }
}
