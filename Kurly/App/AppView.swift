//
//  AppView.swift
//  Kurly
//
//  Created by 김승율 on 3/28/26.
//

import ComposableArchitecture
import SwiftUI

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            switch store.scope(state: \.root, action: \.root).case {
            case let .search(store):
                SearchView(store: store)
            }
        } destination: { store in
            switch store.case {
            case let .webView(store):
                WebView(store: store)
            }
        }
    }
}
