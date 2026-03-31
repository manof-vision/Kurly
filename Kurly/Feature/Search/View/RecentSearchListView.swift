//
//  RecentSearchListView.swift
//  Kurly
//
//  Created by 김승율 on 3/31/26.
//

import SwiftUI

struct RecentSearchListView: View {
    let recentSearches: [RecentSearchModel]
    var onSelect: (RecentSearchModel) -> Void
    var onDelete: (RecentSearchModel) -> Void
    var onDeleteAll: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(StringConstant.recentSearch)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            ForEach(recentSearches, id: \.keyword) { search in
                HStack {
                    Text(search.keyword)
                        .foregroundColor(.gray)

                    Button {
                        onDelete(search)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .padding(5)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
                .onTapGesture { onSelect(search) }
            }

            HStack {
                Spacer()
                Button(StringConstant.allDelete) { onDeleteAll() }
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
            Divider()
        }
    }
}

#Preview {
    RecentSearchListView(
        recentSearches: [
            RecentSearchModel(keyword: "Swift", date: .now)
        ],
        onSelect: { _ in },
        onDelete: { _ in },
        onDeleteAll: { }
    )
}
