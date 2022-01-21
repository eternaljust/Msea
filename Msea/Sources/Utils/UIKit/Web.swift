//
//  Web.swift
//  Msea
//
//  Created by tzqiang on 2022/1/6.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import WebKit

struct Web: UIViewRepresentable {
    @Environment(\.colorScheme) private var colorScheme

    var url: URL?
    var bodyHTMLString: String?
    var didFinish: ((_ scrollHeight: CGFloat) -> Void)?
    var decisionHandler: ((_ url: URL?) -> Void)?

    typealias UIViewType = WKWebView

    func makeCoordinator() -> Web.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.navigationDelegate = context.coordinator
//        webView.allowsLinkPreview = false

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = url {
            let requst = URLRequest(url: url)
            uiView.load(requst)
        } else if let bodyHTMLString = bodyHTMLString {
            let theme = colorScheme == .light ? "light" : "dark"
            if let stylePath = Bundle.main.path(forResource: "style", ofType: "css"), let themePath = Bundle.main.path(forResource: theme, ofType: "css") {
                if let cssString = try? String(contentsOfFile: stylePath), let themeString = try? String(contentsOfFile: themePath) {
                    let head = "<head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no\"><style>\(cssString + themeString)</style></head>"
                    let body = "<body><div id=\"Wrapper\">\(bodyHTMLString)</div></body>"
                    let html = "<html>\(head)\(body)</html>"
                    uiView.loadHTMLString(html, baseURL: nil)
                }
            }
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: Web

        init(_ parent: Web) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { height, _ in
                DispatchQueue.main.async {
                    if let height = height as? CGFloat, let block = self.parent.didFinish {
                        block(height)
                    }
                }
            })
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let hander = self.parent.decisionHandler, let url = navigationAction.request.url, !url.absoluteString.contains("about:blank") {
                decisionHandler(.cancel)
                hander(url)
            } else {
                decisionHandler(.allow)
            }
        }
    }
}

struct Web_Previews: PreviewProvider {
    static var previews: some View {
        Web()
    }
}
