//
//  Log.swift
//  Kurly
//
//  Created by 김승율 on 3/30/26.
//

import Foundation

#if DEBUG
    import os

    enum Log {
        private static let logger = Logger(
            subsystem: "Kurly",
            category: "normal"
        )

        static func getFileInfo(fileID: StaticString, line: UInt) -> String {
            return "[\((String(describing: fileID) as NSString).lastPathComponent): \(line)Line]"
        }

        static func debug(_ message: String, fileID: StaticString = #fileID, line: UInt = #line) {
            logger.debug("\(getFileInfo(fileID: fileID, line: line)) \(message, privacy: .public)")
        }

        static func error(_ message: String, fileID: StaticString = #fileID, line: UInt = #line) {
            logger.fault("\(getFileInfo(fileID: fileID, line: line)) \(message, privacy: .public)")
        }
    }

#else
    enum Log {
        static func debug(_ message: String, category: Any? = nil) {}
        static func error(_ message: String, category: Any? = nil) {}
    }
#endif
