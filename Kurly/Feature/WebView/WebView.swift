//
//  WebView.swift
//  Kurly
//
//  Created by 김승율 on 3/30/26.
//

import ComposableArchitecture
import SwiftUI
import WebKit

struct WebView: View {
    @Bindable var store: StoreOf<WebViewStore>
    
    var body: some View {
        BaseView(store: store.scope(state: \.base, action: \.base)) {
            if let url = URL(string: store.url) {
                WebViewRepresentable(url: url)
            }
        }
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}
}

#Preview {
    WebView(
        store: Store(
            initialState: WebViewStore.State(url: "https://github.com/apple/swift")
        ) {
            WebViewStore()
        }
    )
}
