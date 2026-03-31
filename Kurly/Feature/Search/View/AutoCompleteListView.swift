//
//  AutoCompleteListView.swift
//  Kurly
//
//  Created by 김승율 on 3/31/26.
//

import SwiftUI

struct AutoCompleteListView: View {
    let autoCompletions: [RecentSearchModel]
    var onSelect: (RecentSearchModel) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(autoCompletions, id: \.keyword) { search in
                Button {
                    onSelect(search)
                } label: {
                    HStack {
                        Text(search.keyword)
                            .foregroundColor(.gray)
                        Spacer()
                        
                        Text(search.date.formatted(.dateTime.month(.twoDigits).day(.twoDigits)))
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
    }
}

#Preview {
    AutoCompleteListView(
        autoCompletions: [
            RecentSearchModel(keyword: "Swift", date: .now)
        ],
        onSelect: { _ in }
    )
}
