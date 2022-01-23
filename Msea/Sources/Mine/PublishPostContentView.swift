//
//  PublishPostContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/13.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

struct PublishPostContentView: View {
    var plate = PostPlate.life

    @State private var canPublish = false
    @State private var naviTitle = "发表帖子"
    @State private var title = ""
    @State private var content = ""
    @FocusState private var focused: Bool
    @EnvironmentObject var hud: HUDState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            if canPublish {
                VStack(alignment: .leading) {
                    Text("标题")

                    TextField("可输入 80 个字符", text: $title)
                        .textFieldStyle(.roundedBorder)

                    Text("内容")

                    TextEditor(text: $content)
                        .multilineTextAlignment(.leading)
                        .font(.font12)
                        .focused($focused)
                        .onChange(of: content) { newValue in
                            print(newValue)
                        }
                        .border(.secondary)

                    Spacer()
                }
                .padding([.leading, .trailing], 10)
            } else {
                Text("抱歉，您没有权限在该版块发帖")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle(naviTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        await publish()
                    }
                } label: {
                    Text("发表")
                }
            }
        }
        .task {
            await loadData()
        }
        .onAppear {
            if !UIDevice.current.isPad {
                TabBarTool.showTabBar(false)
            }
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/forum.php?mod=post&action=newthread&fid=\(plate.fid)")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            request.addValue(UserAgentType.mac.description, forHTTPHeaderField: HTTPHeaderField.userAgent.description)
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let error = html.at_xpath("//div[@class='alert_error']", namespaces: nil)?.text, error.contains("没有权限") {
                    canPublish = false
                } else {
                    canPublish = true
                }
                let a = html.xpath("//div[@class='z']/a", namespaces: nil)
                var plates = [String]()
                a.forEach { element in
                    if let text = element.text, !text.contains("虫部落") {
                        plates.append(text)
                    }
                }
                if !plates.isEmpty {
                    naviTitle = plates.joined(separator: "·")
                }

                html.getFormhash()
            }
        }
    }

    private func publish() async {
        focused.toggle()
        if title.isEmpty || content.isEmpty {
            hud.show(message: "抱歉，您尚未输入标题或内容")
            return
        }
        if title.count >= 80 {
            hud.show(message: "抱歉，您的标题不能超过 80 个字符")
            return
        }

        // tags
        Task {
            let time = Int(Date().timeIntervalSince1970)
            let parames = "&formhash=\(UserInfo.shared.formhash)&subject=\(title)&message=\(content)&posttime=\(time)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/forum.php?mod=post&action=newthread&fid=\(plate.fid)&extra=&topicsubmit=yes&wysiwyg=0&typeid=0&checkbox=0&replycredit_times=1&replycredit_extcredits=0&replycredit_membertimes=1&replycredit_random=100&allownoticeauthor=1&save=0\(parames)")!
            // swiftlint:enable force_unwrapping
            print(url.absoluteString)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let text = html.toHTML, text.contains("刚刚") {
                    hud.show(message: "发表成功")
                    dismiss()
                } else {
                    hud.show(message: "发表失败")
                }
            }
        }
    }
}

struct PublishPostContentView_Previews: PreviewProvider {
    static var previews: some View {
        PublishPostContentView()
    }
}
