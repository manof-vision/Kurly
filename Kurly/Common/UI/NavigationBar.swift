//
//  NavigationBar.swift
//  Kurly
//
//  Created by 김승율 on 3/30/26.
//

import SwiftUI

struct NavigationBar: View {
    let onBack: () -> Void
    
    var body: some View {
        HStack {
            Button {
                onBack()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
                    .padding(20)
            }
            Spacer()
        }
        .frame(height: 44)
    }
}
