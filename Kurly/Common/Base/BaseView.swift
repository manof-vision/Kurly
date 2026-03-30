//
//  BaseView.swift
//  Kurly
//
//  Created by 김승율 on 3/30/26.
//

import ComposableArchitecture
import SwiftUI

struct BaseView<Content: View>: View {
    @Bindable var store: Store<BaseStore.State, BaseStore.Action>
    var isShowNaviBar = true
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            if isShowNaviBar {
                NavigationBar(
                    onBack: { store.send(.toNavigation(.pop)) }
                )
            }

            content()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar(.hidden, for: .navigationBar)
        .overlay {
            if store.isLoading {
                LoadingView()
            } else if let message = store.alertMessage {
                AlertView(
                    message: message,
                    confirmBtnTap: { store.send(.fromFeature(.hideAlertView)) }
                )
            }
        }
    }
}

