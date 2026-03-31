//
//  KurlyApp.swift
//  Kurly
//
//  Created by 김승율 on 3/28/26.
//

import ComposableArchitecture
import SwiftUI

@main
struct KurlyApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(initialState: AppFeature.State()) {
                    AppFeature()
                }
            )
        }
    }
}
