//
//  TopicDetailContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/6.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

struct TopicDetailContentView: View {
    var tid: String = ""

    @State private var action = ""
    @State private var title = ""
    @State private var commentCount = ""
    @State private var comments = [TopicCommentModel]()
    @State private var isHidden = false
    @State private var page = 1
    @State private var isRefreshing = false
    @State private var nextPage = false
    @State private var inputComment = ""
    @FocusState private var focused: Bool
    @State private var needLogin = false
    @EnvironmentObject private var hud: HUDState
    @State private var isReply = false
    @State private var replyName = ""
    @State private var replyContent = ""
    @State private var replyAction = ""
    @FocusState private var replyFocused: Bool

    var body: some View {
        ZStack {
            VStack {
                List {
                    Section {
                        ForEach(comments, id: \.id) { comment in
                            VStack(alignment: .leading) {
                                HStack {
                                    AsyncImage(url: URL(string: comment.avatar)) { image in
                                        image.resizable()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(5)

                                    VStack(alignment: .leading) {
                                        Text(comment.name)
                                            .font(.headline)
                                        Text(comment.time)
                                            .font(.footnote)
                                    }
                                }
                                .onAppear {
                                    if comment.id == comments.last?.id {
                                        if nextPage {
                                            page += 1
                                            Task {
                                                await loadData()
                                            }
                                        }
                                    }
                                }

                                if comment.isText {
                                    Text(comment.content)
                                        .font(.font14)
                                        .multilineTextAlignment(.leading)
                                } else {
                                    Web(bodyHTMLString: comment.content, didFinish: { scrollHeight in
                                        if comment.webViewHeight == .zero, let index = comments.firstIndex(where: { obj in obj.id == comment.id }) {
                                            var model = comment
                                            model.webViewHeight = scrollHeight
                                            model.id = UUID()
                                            if index < comments.count, comments.count != 1 {
                                                comments.replaceSubrange(index..<(index + 1), with: [model])
                                            } else {
                                                comments = [model]
                                            }
                                        }
                                    })
                                        .frame(height: comment.webViewHeight)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                replyName = comment.name
                                replyAction = comment.reply
                                focused = false
                                isReply = true
                                replyFocused.toggle()
                            }
                        }
                    } header: {
                        TopicDetailHeaderView(title: title, commentCount: commentCount)
                    }
                }
                .simultaneousGesture(DragGesture().onChanged({ _ in
                    focused = false
                    isReply = false
                    replyFocused = false
                }))
                .listStyle(.plain)
                .refreshable {
                    page = 1
                    await loadData()
                }
                .task {
                    if !isHidden {
                        await loadData()
                    }
                }

                Spacer()

                ZStack {
                    HStack {
                        TextEditor(text: $inputComment)
                            .multilineTextAlignment(.leading)
                            .font(.font12)
                            .focused($focused)
                            .onChange(of: inputComment) { newValue in
                                print(newValue)
                            }
                            .border(Color.theme)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 0))

                        Spacer()

                        Button("评论") {
                            if !UserInfo.shared.isLogin() {
                                needLogin.toggle()
                            } else {
                                Task {
                                    await comment()
                                }
                            }
                        }
                            .offset(x: 0, y: -10)
                            .padding(.trailing, 10)
                    }
                    .frame(height: 60)
                    .isHidden(isReply)

                    VStack {
                        Text("回复\(replyName)")

                        HStack {
                            TextEditor(text: $replyContent)
                                .multilineTextAlignment(.leading)
                                .font(.font12)
                                .focused($replyFocused)
                                .onChange(of: replyContent) { newValue in
                                    print(newValue)
                                }
                                .border(Color.theme)
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 0))

                            Spacer()

                            Button("回复") {
                                if !UserInfo.shared.isLogin() {
                                    needLogin.toggle()
                                } else {
                                    Task {
                                        await getReply()
                                    }
                                }
                            }
                                .offset(x: 0, y: -10)
                                .padding(.trailing, 10)
                        }
                    }
                    .frame(height: 100)
                    .isHidden(!isReply)
                }
            }
            .keyboardAdaptive()

            ProgressView()
                .isHidden(isHidden)
        }
        .edgesIgnoringSafeArea([.bottom])
        .navigationTitle("帖子详情")
        .onAppear {
            TabBarTool.showTabBar(false)
        }
        .sheet(isPresented: $needLogin) {
            LoginContentView()
        }
    }

    private func loadData() async {
        isRefreshing = true
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/forum.php?mod=viewthread&tid=\(tid)&extra=&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let text = html.at_xpath("//div[@id='f_pst']/form/@action", namespaces: nil)?.text {
                    action = text
                }
                if let text = html.at_xpath("//td[@class='plc ptm pbn vwthd']/h1/span", namespaces: nil)?.text {
                    title = text
                }
                if let text1 = html.at_xpath("//td[@class='plc ptm pbn vwthd']/div[@class='ptn']/span[2]", namespaces: nil)?.text, let text2 = html.at_xpath("//td[@class='plc ptm pbn vwthd']/div[@class='ptn']/span[5]", namespaces: nil)?.text {
                    commentCount = "查看: \(text1)  |  回复: \(text2)"
                }
                if let text = html.toHTML, text.contains("下一页") {
                    nextPage = true
                } else {
                    nextPage = false
                }
                let node = html.xpath("//table[@class='plhin']", namespaces: nil)
                var list = [TopicCommentModel]()
                node.forEach { element in
                    var comment = TopicCommentModel()
                    if let avatar = element.at_xpath("//div[@class='avatar']//img/@src", namespaces: nil)?.text {
                        comment.avatar = avatar
                    }
                    if let name = element.at_xpath("//div[@class='authi']/a", namespaces: nil)?.text {
                        comment.name = name
                    }
                    if let time = element.at_xpath("//div[@class='authi']/em", namespaces: nil)?.text {
                        comment.time = time
                    }
                    let a = element.xpath("//div[@class='pob cl']//a", namespaces: nil)
                    a.forEach { ele in
                        if let text = ele.text, text.contains("回复") {
                            if let reply = ele.at_xpath("/@href", namespaces: nil)?.text {
                                print(reply)
                                comment.reply = reply
                            }
                        }
                    }
                    var table = element.at_xpath("//div[@class='t_fsz']/table", namespaces: nil)
                    if table?.toHTML == nil {
                        table = element.at_xpath("//div[@class='pcbs']/table", namespaces: nil)
                    }
                    if table?.toHTML == nil {
                        table = element.at_xpath("//div[@class='pcbs']", namespaces: nil)
                    }
                    if let content = table?.toHTML {
                        comment.content = content
                        if content.contains("font") || content.contains("strong") || content.contains("color") || content.contains("quote") || content.contains("</a>") {
                            comment.isText = false
                            comment.content = content.replacingOccurrences(of: "</blockquote></div>\n<br>", with: "</blockquote></div>")
                            if content.contains("file") && content.contains("src") {
                                comment.content = comment.content.replacingOccurrences(of: "src=\"static/image/common/none.gif\"", with: "")
                                comment.content = comment.content.replacingOccurrences(of: "file", with: "src")
                            }
                        } else {
                            comment.content = table?.text ?? ""
                        }
                        if let i = comment.content.firstIndex(of: "\r\n") {
                            comment.content.remove(at: i)
                        }
                    }
                    list.append(comment)
                }
                html.getFormhash()

                if page == 1 {
                    comments = list
                    isRefreshing = false
                } else {
                    comments += list
                }
                isHidden = true
            }
        }
    }

    private func comment() async {
        Task {
            if UserInfo.shared.formhash.isEmpty {
                needLogin.toggle()
                return
            }

            let message = inputComment.replacingOccurrences(of: " ", with: "")
            let time = Int(Date().timeIntervalSince1970)
            // swiftlint:disable force_unwrapping
            let parames = "&formhash=\(UserInfo.shared.formhash)&message=\(message)&posttime=\(time)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let url = URL(string: "https://www.chongbuluo.com/\(action)\(parames)")!
            print(url.absoluteString)
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.httpMethod = "POST"
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let text = html.toHTML, text.contains("刚刚") || text.contains("秒前") {
                    inputComment = ""
                    hud.show(message: "评论成功")
                } else {
                    hud.show(message: "评论失败")
                }
                focused = false
                await loadData()
            }
        }
    }

    private func getReply() async {
        if replyContent.isEmpty {
            hud.show(message: "请输入回复内容")
            return
        }

        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/\(replyAction)")!
            print(url.absoluteString)
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.httpMethod = "POST"
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let time = Int(Date().timeIntervalSince1970)
                var param = "&formhash=\(UserInfo.shared.formhash)&message=\(replyContent)&posttime=\(time)&checkbox=0&wysiwyg=0&replysubmit=yes"
                if let noticeauthor = html.at_xpath("//input[@name='noticeauthor']/@value", namespaces: nil)?.text {
                    param += "&noticeauthor=\(noticeauthor)"
                }
                // FIXME: 回复提交提示 [quote][url=forum.php?mod=redirect
                if let noticetrimstr = html.at_xpath("//input[@name='noticetrimstr']/@value", namespaces: nil)?.text {
                    param += "&noticetrimstr=\(noticetrimstr)"
                }
                if let noticeauthormsg = html.at_xpath("//input[@name='noticeauthormsg']/@value", namespaces: nil)?.text {
                    param += "&noticeauthormsg=\(noticeauthormsg)"
                }
                if let reppid = html.at_xpath("//input[@name='reppid']/@value", namespaces: nil)?.text {
                    param += "&reppid=\(reppid)"
                }
                if let reppost = html.at_xpath("//input[@name='reppost']/@value", namespaces: nil)?.text {
                    param += "&reppost=\(reppost)"
                }
                param = param.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                await reply(param)
            }
        }
    }

    private func reply(_ param: String) async {
        Task {
            var action = replyAction.components(separatedBy: "&repquote=")[0]
            action += "&extra=&replysubmit=yes"
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/\(action)\(param)")!
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.httpMethod = "POST"
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let text = html.toHTML, text.contains("刚刚") || text.contains("秒前") {
                    replyContent = ""
                    hud.show(message: "回复成功")
                } else {
                    hud.show(message: "回复失败")
                }
                replyFocused = false
                await loadData()
            }
        }
    }
}

struct TopicDetailHeaderView: View {
    var title = ""
    var commentCount = ""
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title3)

            Text(commentCount)
        }
    }
}

struct TopicDetailContentView_Previews: PreviewProvider {
    static var previews: some View {
        TopicDetailContentView()
    }
}

struct TopicCommentModel: Identifiable {
    var id = UUID()
    var uid = ""
    var reply = ""
    var name = ""
    var avatar = ""
    var lv = ""
    var time = ""
    var content = ""
    var isText = true
    var webViewHeight: CGFloat = .zero
}