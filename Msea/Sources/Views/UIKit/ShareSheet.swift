//
//  ShareSheet.swift
//  Msea
//
//  Created by Awro on 2022/2/2.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.modalPresentationStyle = .pageSheet

        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}
