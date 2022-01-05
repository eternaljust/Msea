//
//  GifImage.swift
//  Msea
//
//  Created by tzqiang on 2022/1/5.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import WebKit

struct GifImage: UIViewRepresentable {
    var url: URL?

    typealias UIViewType = WKWebView

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        if let url = url, let data = try? Data(contentsOf: url) {
            webView.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: url.deletingLastPathComponent())
        }
        webView.scrollView.isScrollEnabled = false

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.reload()
    }
}

struct GifImage_Previews: PreviewProvider {
    static var previews: some View {
        GifImage()
    }
}
