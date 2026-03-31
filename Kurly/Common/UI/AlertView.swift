//
//  AlertView.swift
//  Kurly
//
//  Created by 김승율 on 3/30/26.
//

import SwiftUI

struct AlertView: View {
    let message: String
    let confirmBtnTap: () -> Void

    var body: some View {
        ZStack {
            DimmingView()

            VStack(spacing: 0) {
                Text(message)
                    .padding(.top, 20)
                    .padding(.horizontal, 20)

                Spacer(minLength: 20)

                Button(StringConstant.confirm) {
                    confirmBtnTap()
                }
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 100)
            .fixedSize(horizontal: false, vertical: true)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.white)
            )
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

#Preview {
    AlertView(
        message: "test message",
        confirmBtnTap: { Log.debug("test Tap") }
    )
}
