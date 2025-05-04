//
//  PublishPostContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/13.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna
import EJExtension

struct PublishPostContentView: View {
    var plate = PostPlate.life

    @State private var canPublish = false
    @State private var naviTitle = "发表帖子"
    @State private var title = ""
    @State private var content = ""

    @State private var type = PostboxTypeModel()
    @State private var typeList = [PostboxTypeModel]()

    @FocusState private var focused: Bool
    @StateObject private var hud = HUDState()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            if canPublish {
                ScrollView {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("标题")

                            Spacer()

                            if !typeList.isEmpty {
                                Menu {
                                    ForEach(typeList) { item in
                                        Button {
                                            type = item
                                        } label: {
                                            Text(item.title)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(type.title)

                                        Image(systemName: "arrowtriangle.down.fill")
                                            .resizable()
                                            .frame(width: 8, height: 8)
                                            .padding(.leading, -5)
                                    }
                                }
                            }
                        }

                        TextField("可输入 80 个字符", text: $title)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.done)

                        Text("内容")

                        TextEditor(text: $content)
                            .multilineTextAlignment(.leading)
                            .font(.font16)
                            .focused($focused)
                            .onChange(of: content, { _, newValue in
                                print(newValue)
                            })
                            .border(.secondary)
                            .frame(height: 400)
                    }
                    .simultaneousGesture(DragGesture().onChanged({ _ in
                        focused = false
                    }))
                }
                .padding([.top, .leading, .trailing], 10)
            } else {
                Text("抱歉，您没有权限在该版块发帖")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle(naviTitle)
        .hud(isPresented: $hud.isPresented) {
            Text(hud.message)
        }
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
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let error = html.at_xpath("//div[@class='alert_error']")?.text, error.contains("没有权限") {
                    canPublish = false
                } else {
                    canPublish = true
                }
                let a = html.xpath("//div[@class='z']/a")
                var plates = [String]()
                a.forEach { element in
                    if let text = element.text, !text.contains("虫部落") {
                        plates.append(text)
                    }
                }
                if !plates.isEmpty {
                    naviTitle = plates.joined(separator: "·")
                }
                let type = html.xpath("//select[@id='typeid']/option")
                var list = [PostboxTypeModel]()
                type.forEach { element in
                    var model = PostboxTypeModel()
                    if let title = element.text {
                        model.title = title
                    }
                    if let id = element.at_xpath("/@value")?.text {
                        model.typeid = id
                    }
                    list.append(model)
                }
                typeList = list
                if !typeList.isEmpty {
                    self.type = typeList[0]
                }

                html.getFormhash()
            }
        }
    }

    private func publish() async {
        focused = false
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
            let parames = "&formhash=\(UserInfo.shared.formhash)&subject=\(title)&message=\(content)&typeid=\(type.typeid)&posttime=\(time)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/forum.php?mod=post&action=newthread&fid=\(plate.fid)&extra=&topicsubmit=yes&wysiwyg=0&checkbox=0&replycredit_times=1&replycredit_extcredits=0&replycredit_membertimes=1&replycredit_random=100&allownoticeauthor=1&save=0\(parames)")!
            // swiftlint:enable force_unwrapping
            print(url.absoluteString)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let text = html.toXML, text.contains("刚刚") || text.contains("秒前") {
                    NotificationCenter.default.post(name: .postPublish, object: nil, userInfo: nil)
//                    hud.show(message: "发表成功")
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
