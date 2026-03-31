//
//  SearchBarView.swift
//  Kurly
//
//  Created by 김승율 on 3/30/26.
//

import SwiftUI
                                                                                                        
struct SearchBarView: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    var onSubmit: () -> Void
    var onCancel: () -> Void

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField(StringConstant.searchTextFieldPlaceholder, text: $text)
                    .focused(isFocused)
                    .onSubmit { onSubmit() }

                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(10)

            if !text.isEmpty {
                Button(StringConstant.cancel) { onCancel() }
                    .foregroundColor(.purple)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

