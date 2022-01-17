//
//  Safari.swift
//  Msea
//
//  Created by tzqiang on 2022/1/17.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import SafariServices

struct Safari: UIViewControllerRepresentable {
    var url: URL?

    typealias UIViewControllerType = SFSafariViewController

    func makeUIViewController(context: Context) -> SFSafariViewController {
        if let url = url {
            return SFSafariViewController(url: url)
        } else {
            // swiftlint:disable force_unwrapping
            return SFSafariViewController(url: URL(string: "https://github.com/")!)
            // swiftlint:enable force_unwrapping
        }
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
    }
}

struct Safari_Previews: PreviewProvider {
    static var previews: some View {
        Safari()
    }
}
