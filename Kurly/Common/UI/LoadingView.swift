//
//  LoadingView.swift
//  Kurly
//
//  Created by 김승율 on 3/30/26.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            DimmingView()

            ProgressView()
                .tint(.white)
                .scaleEffect(2.0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

#Preview {
    LoadingView()
}
