//
//  AppFeature.swift
//  Kurly
//
//  Created by 김승율 on 3/28/26.
//

import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var root: Root.State = .search(SearchStore.State())
        var path: StackState<Path.State> = .init()
    }

    enum Action {
        case root(Root.Action)
        case path(StackActionOf<Path>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .root(.search(.base(.toNavigation(navigation)))):
                return handleNavigationAction(navigation, state: &state)

            case let .path(.element(_, action: .webView(.base(.toNavigation(navigation))))):
                return handleNavigationAction(navigation, state: &state)
                
            default:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        Scope(state: \.root, action: \.root) { Root.body }
    }

    @Reducer
    enum Root {
        case search(SearchStore)
    }

    @Reducer
    enum Path {
        case webView(WebViewStore)
    }

    private func handleNavigationAction(_ navigationAction: NavigationAction, state: inout State) -> Effect<Action> {
        switch navigationAction {
        case let .setRoot(screen):
            state.root = screen
            state.path = .init()
            
        case let .push(screen):
            state.path.append(screen)

        case .pop:
            if !state.path.isEmpty {
                state.path.removeLast()
            }
        }
        
        return .none
    }
}

extension AppFeature.Root.State: Equatable {}
extension AppFeature.Path.State: Equatable {}

@CasePathable
enum NavigationAction: Equatable {
    case setRoot(AppFeature.Root.State)
    case push(AppFeature.Path.State)
    case pop
}
