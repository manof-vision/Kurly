//
//  WebViewStore.swift
//  Kurly
//
//  Created by 김승율 on 3/30/26.
//

import ComposableArchitecture

@Reducer
struct WebViewStore {
    @ObservableState
    struct State: Equatable {
        var base: BaseStore.State = .init()
        var url: String = ""
    }

    enum Action: Equatable {
        case base(BaseStore.Action)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            default:
                return .none
            }
        }
        Scope(state: \.base, action: \.base) { BaseStore() }
    }
}
