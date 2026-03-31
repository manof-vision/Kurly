//
//  SearchView.swift
//  Kurly
//
//  Created by 김승율 on 3/30/26.
//

import ComposableArchitecture
import SwiftUI

struct SearchView: View {
    @Bindable var store: StoreOf<SearchStore>
    
    var body: some View {
        BaseView(store: store.scope(state: \.base, action: \.base)) {
            
        }
    }
}
