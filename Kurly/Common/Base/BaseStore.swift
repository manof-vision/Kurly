//
//  BaseStore.swift
//  Kurly
//
//  Created by 김승율 on 3/30/26.
//

import ComposableArchitecture

@Reducer
struct BaseStore {
    @ObservableState
    struct State: Equatable {
        var isLoading = false
        var alertMessage: String?
    }

    enum Action: Equatable {
        case fromFeature(BaseAction)
        case toNavigation(NavigationAction)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .fromFeature(baseAction):
                return handleFeatureRequest(baseAction: baseAction, state: &state)

            default:
                return .none
            }
        }
    }

    private func handleFeatureRequest(baseAction: BaseAction, state: inout State) -> Effect<Action> {
        switch baseAction {
        case let .showLoadingView(bool):
            state.isLoading = bool
            return .none

        case let .showAlertView(message):
            state.alertMessage = message
            return .none

        case .hideAlertView:
            state.alertMessage = nil
            return .none
        }
    }
}

@CasePathable
enum BaseAction: Equatable {
    case showLoadingView(Bool)
    case showAlertView(String)
    case hideAlertView
}
