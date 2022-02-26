//
//  SVGImage.swift
//  Msea
//
//  Created by Awro on 2022/2/26.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import WebKit

struct SVGImage: UIViewRepresentable {
    var url: URL?

    typealias UIViewType = WKWebView

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        if let url = url, let data = try? Data(contentsOf: url) {
            webView.load(data, mimeType: "image/svg", characterEncodingName: "UTF-8", baseURL: url.deletingLastPathComponent())
        }
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.contentMode = .scaleAspectFill

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.reload()
    }
}

struct SVGImage_Previews: PreviewProvider {
    static var previews: some View {
        SVGImage()
    }
}
