//
//  SiriButton.swift
//  Msea
//
//  Created by tzqiang on 2022/6/15.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import IntentsUI

enum SiriButtonLayout: Int {
    case left
    case center
    case right
}

struct SiriButton: UIViewControllerRepresentable {
    let shortcut: INShortcut
    let layout: SiriButtonLayout

    @Environment(\.colorScheme) private var colorScheme

    func makeUIViewController(context: Context) -> SiriUIViewController {
        return SiriUIViewController(shortcut: shortcut, layout: layout)
    }

    func updateUIViewController(_ uiViewController: SiriUIViewController, context: Context) {
        uiViewController.siriButton.setStyle(colorScheme == .light ? .whiteOutline : .blackOutline)
    }
}

class SiriUIViewController: UIViewController {
    let shortcut: INShortcut
    let layout: SiriButtonLayout

    lazy var siriButton: INUIAddVoiceShortcutButton = {
        let button = INUIAddVoiceShortcutButton(style: .blackOutline)
        button.shortcut = shortcut
        button.translatesAutoresizingMaskIntoConstraints = false
        button.delegate = self

        return button
    }()

    init(shortcut: INShortcut, layout: SiriButtonLayout) {
        self.shortcut = shortcut
        self.layout = layout
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(siriButton)
        view.centerYAnchor.constraint(equalTo: siriButton.centerYAnchor).isActive = true
        switch layout {
        case .left:
            view.leftAnchor.constraint(equalTo: siriButton.leftAnchor).isActive = true
        case .center:
            view.centerXAnchor.constraint(equalTo: siriButton.centerXAnchor).isActive = true
        case .right:
            view.rightAnchor.constraint(equalTo: siriButton.rightAnchor).isActive = true
        }
    }
}

extension SiriUIViewController: INUIAddVoiceShortcutButtonDelegate {
    func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        addVoiceShortcutViewController.delegate = self
        addVoiceShortcutViewController.modalPresentationStyle = .formSheet
        present(addVoiceShortcutViewController, animated: true)
    }

    func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        editVoiceShortcutViewController.delegate = self
        editVoiceShortcutViewController.modalPresentationStyle = .formSheet
        present(editVoiceShortcutViewController, animated: true)
    }
}

extension SiriUIViewController: INUIAddVoiceShortcutViewControllerDelegate {
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true)
    }

    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true)
    }
}

extension SiriUIViewController: INUIEditVoiceShortcutViewControllerDelegate {
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true)
    }

    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        controller.dismiss(animated: true)
    }

    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true)
    }
}
