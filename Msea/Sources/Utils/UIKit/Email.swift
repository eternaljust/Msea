//
//  Email.swift
//  Msea
//
//  Created by tzqiang on 2022/1/18.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import MessageUI

struct Email: UIViewControllerRepresentable {
    typealias UIViewControllerType = MFMailComposeViewController

    @EnvironmentObject private var hud: HUDState
    @Binding var isShowing: Bool

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool
        let parent: Email

        init(isShowing: Binding<Bool>, parent: Email) {
            _isShowing = isShowing
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                isShowing = false
            }

            switch result {
            case .sent:
                parent.hud.show(message: "感谢您的反馈，我会尽量给您答复。")
            case .failed:
                parent.hud.show(message: "邮件发送失败")
            default:
                break
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing, parent: self)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setSubject("Msea \(UIApplication.appVersion)(\(UIApplication.appBuild)) 问题反馈")
        vc.setToRecipients(["eternal.just@gmail.com"])
        let body =
        """
        设备来自：\(UIDevice.current.modelName) / \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)

        1.问题描述（长按可插入截图）。


        2.能否复现问题？可以的话给出具体的步骤。


        3.非 bug 反馈，有其他的想法。


        """
        vc.setMessageBody(body, isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
    }
}
