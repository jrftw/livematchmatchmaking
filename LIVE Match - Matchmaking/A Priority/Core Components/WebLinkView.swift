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
    // MARK: - Properties
    public let title: String
    public let urlString: String
    
    @State private var canGoBack = false
    @State private var canGoForward = false
    
    // MARK: - Init
    public init(title: String, urlString: String) {
        print("[WebLinkView] init called. title: \(title), urlString: \(urlString)")
        self.title = title
        self.urlString = urlString
    }
    
    // MARK: - Body
    public var body: some View {
        let _ = print("[WebLinkView] body invoked. Building WebViewWrapper with title: \(title), urlString: \(urlString)")
        
        return WebViewWrapper(urlString: urlString, canGoBack: $canGoBack, canGoForward: $canGoForward)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
fileprivate struct WebViewWrapper: UIViewRepresentable {
    // MARK: - Properties
    let urlString: String
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    
    // MARK: - makeUIView
    func makeUIView(context: Context) -> WKWebView {
        print("[WebViewWrapper] makeUIView called with urlString: \(urlString)")
        
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        if let url = URL(string: urlString) {
            print("[WebViewWrapper] Attempting to load URL: \(url.absoluteString)")
            let req = URLRequest(url: url)
            webView.load(req)
        } else {
            print("[WebViewWrapper] Invalid URL string: \(urlString). No request loaded.")
        }
        return webView
    }
    
    // MARK: - updateUIView
    func updateUIView(_ uiView: WKWebView, context: Context) {
        print("[WebViewWrapper] updateUIView called. No incremental updates implemented.")
    }
    
    // MARK: - makeCoordinator
    func makeCoordinator() -> Coordinator {
        print("[WebViewWrapper] makeCoordinator called. Returning Coordinator instance.")
        return Coordinator(self)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewWrapper
        
        init(_ parent: WebViewWrapper) {
            print("[WebViewWrapper.Coordinator] init called.")
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("[WebViewWrapper.Coordinator] webView didFinish navigation. Checking canGoBack/canGoForward.")
            parent.canGoBack = webView.canGoBack
            parent.canGoForward = webView.canGoForward
            print("[WebViewWrapper.Coordinator] canGoBack: \(parent.canGoBack), canGoForward: \(parent.canGoForward)")
        }
    }
}
