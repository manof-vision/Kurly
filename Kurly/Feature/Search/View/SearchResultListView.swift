//
//  SearchResultListView.swift
//  Kurly
//
//  Created by 김승율 on 3/31/26.
//

import SwiftUI

struct SearchResultListView: View {
    let totalCount: Int
    let repositories: [Repository]
    let hasMorePages: Bool
    var onSelect: (Repository) -> Void
    var onLoadMore: () -> Void
    var onScrollChanged: ((CGFloat) -> Void)? = nil
    
    var body: some View {
        Text("\(totalCount.formatted())\(StringConstant.count) \(StringConstant.repository)")
            .font(.subheadline)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(repositories) { repo in
                    Button {
                        onSelect(repo)
                    } label: {
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: repo.owner.avatarUrl)) { image in
                                image.resizable()
                            } placeholder: {
                                Color(.systemGray5)
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(repo.name)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                Text(repo.owner.login)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .onAppear {
                        let thresholdIndex = max(repositories.count - 7, 0)
                        if let index = repositories.firstIndex(where: { $0.id == repo.id }),
                           index >= thresholdIndex {
                            onLoadMore()
                        }
                    }
                }
                
                if hasMorePages {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding(.vertical, 16)
                }
            }
            .background(
                GeometryReader { geo in
                    let offset = -geo.frame(in: .named("scroll")).origin.y
                    Color.clear
                        .onChange(of: offset) { _, newValue in
                            onScrollChanged?(newValue)
                        }
                }
            )
        }
        .coordinateSpace(name: "scroll")
    }
}

#Preview {
    SearchResultListView(
        totalCount: 256714,
        repositories: [
            Repository(id: 1, name: "swift", htmlUrl: "", owner: Owner(login: "apple", avatarUrl: ""))
        ],
        hasMorePages: false,
        onSelect: { _ in },
        onLoadMore: { }
    )
}
