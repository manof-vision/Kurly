//
//  DimmingView.swift
//  Kurly
//
//  Created by 김승율 on 3/30/26.
//

import SwiftUI

struct DimmingView: View {
    var body: some View {
        Color.dim
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }
}

#Preview {
    DimmingView()
}
