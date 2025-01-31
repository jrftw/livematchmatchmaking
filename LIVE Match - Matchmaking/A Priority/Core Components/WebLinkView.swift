//
//  WebLinkView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/31/25.
//


//
//  WebLinkView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  A simple in-app web view using WKWebView to display external links.
//

import SwiftUI
import WebKit

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct WebLinkView: View {
    public let title: String
    public let urlString: String
    
    @State private var canGoBack = false
    @State private var canGoForward = false
    
    public init(title: String, urlString: String) {
        self.title = title
        self.urlString = urlString
    }
    
    public var body: some View {
        WebViewWrapper(urlString: urlString, canGoBack: $canGoBack, canGoForward: $canGoForward)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
fileprivate struct WebViewWrapper: UIViewRepresentable {
    let urlString: String
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        if let url = URL(string: urlString) {
            let req = URLRequest(url: url)
            webView.load(req)
        }
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewWrapper
        
        init(_ parent: WebViewWrapper) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.canGoBack = webView.canGoBack
            parent.canGoForward = webView.canGoForward
        }
    }
}