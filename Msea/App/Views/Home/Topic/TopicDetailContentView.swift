//
//  TopicDetailContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/6.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna
import Extension

struct TopicDetailContentView: View {
    var tid: String = ""
    /// 石沉大海
    @State var isNodeFid125 = false

    @State private var action = ""
    @State private var comments = [TopicCommentModel]()
    @State private var page = 1
    @State private var nextPage = false
    @State private var isProgressViewHidden = false
    @State private var header = TopicDetailHeaderModel()

    @State private var isSelectedPage = false
    @State private var isConfirming = false
    @State private var fid = ""
    @EnvironmentObject private var selection: TabItemSelection

    @State private var needLogin = false
    @EnvironmentObject private var hud: HUDState

    @State private var inputComment = ""
    @FocusState private var focused: Bool
    @State private var isPresented = false
    @State private var isShowing = false

    @State private var replyName = ""
    @State private var replyContent = ""
    @State private var replyAction = ""
    @FocusState private var replyFocused: Bool
    @State private var isPresentedReply = false
    @State private var isShowingReply = false

    @State private var showAlert = false
    @Environment(\.dismiss) private var dismiss

    @State private var disAgree = false
    @State private var isPosterShielding = false
    @State private var favoriteAction = ""

    @State private var uid = ""
    @State private var isSpace = false
    @State private var newTid = ""
    @State private var isViewthread = false
    @State private var webURLItem: WebURLItem?
    @State private var pid = ""

    @State private var isDaysign = false
    @State private var isCredit = false
    @State private var isRanklist = false
    @State private var isSharePresented = false

    @State private var isNode = false
    @State private var isNodeList = false
    @State private var isTag = false

    @State private var isImagePresented = false

    var body: some View {
        ZStack {
            if disAgree || isPosterShielding {
                TopicDetailTipText(disAgree: disAgree)
            } else {
                VStack {
                    commentList
                }
            }

            progressView
        }
        .edgesIgnoringSafeArea(UIDevice.current.isPad ? [] : [.bottom])
        .navigationTitle("帖子详情")
        .navigationDestination(isPresented: $isTag, destination: {
            TagListContentView(id: header.tagId, searchState: SearchState())
        })
        .navigationDestination(isPresented: $isNodeList, destination: {
            NodeListContentView(nodeTitle: header.nodeTitle, nodeFid: header.nodeFid)
        })
        .navigationDestination(isPresented: $isNode, destination: {
            NodeContentView(gid: header.gid)
        })
        .navigationDestination(isPresented: $isRanklist, destination: {
            RankListContentView()
        })
        .navigationDestination(isPresented: $isCredit, destination: {
            MyCreditContentView()
        })
        .navigationDestination(isPresented: $isDaysign, destination: {
            DaySignContentView()
        })
        .navigationDestination(isPresented: $isViewthread, destination: {
            TopicDetailContentView(tid: newTid)
        })
        .navigationDestination(isPresented: $isSpace, destination: {
            SpaceProfileContentView(uid: uid)
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                toolbarItemMenu
            }
        }
        .fullScreenCover(isPresented: $isImagePresented) {
            imageBrowser
        }
        .sheet(isPresented: $isSharePresented) {
            shareSheet
        }
        .sheet(isPresented: $needLogin) {
            LoginContentView()
        }
        .sheet(item: $webURLItem, content: { item in
            Safari(url: URL(string: item.url))
        })
        .alert("使用条款", isPresented: $showAlert) {
            useAlert
        } message: {
            TermsOfServiceContentView()
        }
        .dialog(isPresented: $isPresented, paddingTop: 100) {
            commentDialog
        }
        .dialog(isPresented: $isPresentedReply, paddingTop: 100) {
            replyDialog
        }
        .onAppear {
            if !UIDevice.current.isPad {
                TabBarTool.showTabBar(false)
            }
            if let first = comments.first {
                isPosterShielding = UserInfo.shared.shieldUsers.contains { $0.uid == first.uid }
                if isPosterShielding {
                    dismiss()
                } else {
                    shieldUsers()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .login, object: nil)) { _ in
            Task {
                await reloadData()
            }
        }
    }

    var commentList: some View {
        ScrollViewReader { proxy in
            List {
                Section {
                    ForEach(comments) { comment in
                        TopicDetailListItemRow(
                            comment: comment,
                            isNodeFid125: isNodeFid125,
                            avatarClick: {
                                if comment.uid == UserInfo.shared.uid {
                                    selection.index = .mine
                                    CacheInfo.shared.selectedTab = .mine
                                } else {
                                    uid = comment.uid
                                    isSpace.toggle()
                                }
                            },
                            webContent: {
                                Web(
                                    bodyHTMLString: comment.content,
                                    isNodeFid125: isNodeFid125,
                                    didFinish: { scrollHeight in
                                        if comment.webViewHeight == .zero,
                                           let index = comments.firstIndex(
                                            where: { obj in obj.id == comment.id }) {
                                            var model = comment
                                            model.webViewHeight = scrollHeight
                                            model.id = UUID()
                                            Task {
                                                if index < comments.count, comments.count != 1 {
                                                    comments.replaceSubrange(index..<(index + 1), with: [model])
                                                } else {
                                                    comments = [model]
                                                }
                                            }
                                        }
                                    },
                                    decisionHandler: { url in
                                        if let url = url {
                                            handler(url: url)
                                        }
                                    },
                                    imageUrlClick: {
                                        isImagePresented.toggle()
                                    })
                                .frame(height: comment.webViewHeight)
                            })
                        .padding([.top, .bottom], 5)
                        .id(comment.pid)
                        .onAppear {
                            if comment.id == comments.last?.id {
                                if nextPage {
                                    Task {
                                        page += 1
                                        isSelectedPage = false
                                        await loadData()
                                    }
                                }
                            }
                        }
                        .swipeActions {
                            if !isNodeFid125 {
                                Button("回复") {
                                    if UserInfo.shared.isLogin() {
                                        replyName = comment.name
                                        replyAction = comment.reply
                                        focused = false
                                        isPresentedReply.toggle()
                                    } else {
                                        needLogin.toggle()
                                    }
                                }
                            }
                        }
                    }
                } header: {
                    TopicDetailListHeader(
                        isConfirming: $isConfirming,
                        isNodeFid125: isNodeFid125,
                        header: header,
                        nodeClick: {
                            selection.index = .node
                            CacheInfo.shared.selectedTab = .node
                            TabBarTool.showTabBar(true)
                        },
                        indexClick: {
                            isNode.toggle()
                        },
                        nodeListClick: {
                            isNodeList.toggle()
                        },
                        tagClick: { id in
                            Task {
                                header.tagId = id
                                isTag.toggle()
                            }
                        },
                        selectedPage: { index in
                            page = index
                            isSelectedPage = true
                            Task {
                                await loadData()
                            }
                        })
                }
            }
            .listStyle(.plain)
            .refreshable {
                Task {
                    await reloadData()
                }
            }
            .task {
                if !isProgressViewHidden {
                    await reloadData()
                }
            }
            .onOpenURL { url in
                if let query = url.query, query.contains("pid=") {
                    let pid = query.components(separatedBy: "=")[1]
                    if Int(pid) != nil {
                        proxy.scrollTo(pid, anchor: .top)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                TopicDetailBottomButton(isNodeFid125:
                                            isNodeFid125) {
                    if UserInfo.shared.isLogin() {
                        isPresented.toggle()
                    } else {
                        needLogin.toggle()
                    }
                }
            }
        }
    }

    var progressView: some View {
        ProgressView()
            .isHidden(isProgressViewHidden)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if !CacheInfo.shared.agreeTermsOfService {
                        showAlert.toggle()
                    }
                }
            }
    }

    var toolbarItemMenu: some View {
        Menu {
            if UserInfo.shared.isLogin() {
                Button {
                    if let action = comments.first?.favorite,
                       UserInfo.shared.isLogin(),
                       !action.isEmpty {
                        favoriteAction = action
                        Task {
                            await favorite()
                        }
                    }
                } label: {
                    Label("收藏", systemImage: "star")
                }
            }

            Button {
                isSharePresented.toggle()
            } label: {
                Label("分享", systemImage: "square.and.arrow.up")
            }

            Menu("举报") {
                ForEach(ReportMenuItem.allCases) { item in
                    Button {
                        Task {
                            await report()
                        }
                    } label: {
                        Text(item.title)
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis")
        }
        .isHidden(disAgree)
    }

    @ViewBuilder
    var shareSheet: some View {
        if let url = URL(string: "https://www.chongbuluo.com/forum.php?mod=viewthread&tid=\(tid)") {
            ShareSheet(items: [
                url
            ])
        }
    }

    @ViewBuilder
    var useAlert: some View {
        Button("不同意", role: .cancel) {
            disAgree = true
            dismiss()
        }

        Button("同意") {
            CacheInfo.shared.agreeTermsOfService = true
            showAlert = false
        }
    }

    var imageBrowser: some View {
        ImageBrowser()
            .overlay(alignment: .topLeading) {
                CloseButton {
                    isImagePresented.toggle()
                }
            }
    }

    var commentDialog: some View {
        VStack {
            HStack {
                Spacer()

                Text("评论帖子")
                    .font(.font17)

                Spacer()

                Button {
                    closeDialog()
                } label: {
                    Image(systemName: "xmark.circle")
                }
            }

            ZStack(alignment: .leading) {
                TextEditor(text: $inputComment)
                    .multilineTextAlignment(.leading)
                    .font(.font16)
                    .focused($focused)
                    .onChange(of: inputComment, { _, newValue in
                        print(newValue)
                    })
                    .border(Color.theme)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 0))

                if inputComment.isEmpty {
                    Text("输入评论内容")
                        .multilineTextAlignment(.leading)
                        .font(.font16)
                        .foregroundColor(.secondary)
                        .padding(EdgeInsets(top: -43, leading: 16, bottom: 30, trailing: 0))
                }
            }

            Button(isShowing ? " " : "发表评论", action: {
                Task {
                    await comment()
                }
            })
            .showProgress(isShowing: $isShowing, color: .white)
            .disabled(isShowing)
            .buttonStyle(BigButtonStyle())
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 10, trailing: 0))
        }
        .frame(width: 300, height: 200)
        .onAppear {
            focused.toggle()
        }
    }

    var replyDialog: some View {
        VStack {
            HStack {
                Spacer()

                Text("回复帖子")
                    .font(.font17)

                Spacer()

                Button {
                    closeDialog()
                } label: {
                    Image(systemName: "xmark.circle")
                }
            }

            ZStack(alignment: .leading) {
                TextEditor(text: $replyContent)
                    .multilineTextAlignment(.leading)
                    .font(.font16)
                    .focused($replyFocused)
                    .onChange(of: replyContent, { _, newValue in
                        print(newValue)
                    })
                    .border(Color.theme)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 0))

                if replyContent.isEmpty {
                    Text("输入回复内容")
                        .multilineTextAlignment(.leading)
                        .font(.font16)
                        .foregroundColor(.secondary)
                        .padding(EdgeInsets(top: -43, leading: 16, bottom: 30, trailing: 0))
                }
            }

            Button(isShowingReply ? " " : "发表回复", action: {
                Task {
                    await getReply()
                }
            })
            .showProgress(isShowing: $isShowingReply, color: .white)
            .disabled(isShowingReply)
            .buttonStyle(BigButtonStyle())
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 10, trailing: 0))
        }
        .frame(width: 300, height: 200)
        .onAppear {
            replyFocused.toggle()
        }
    }
}

extension TopicDetailContentView {
    private func closeDialog() {
        withAnimation {
            focused = false
            if isPresented {
                inputComment = ""
                isPresented.toggle()
            }

            replyFocused = false
            if isPresentedReply {
                replyContent = ""
                isPresentedReply.toggle()
            }

            if !UIDevice.current.isPad {
                TabBarTool.showTabBar(false)
            }
        }
    }

    private func shieldUsers() {
        comments = comments.filter { model in
            !UserInfo.shared.shieldUsers.contains { $0.uid == model.uid }
        }
    }

    private func reloadData() async {
        page = 1
        isSelectedPage = false
        await loadData()
    }

    private func loadData() async {
        print("pageSize: \(header.pageSize)")
        print("page: \(page)")
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/thread-\(tid)-\(page)-1.html")!
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let href = html.at_xpath("//div[@class='bm cl']/div[@class='z']/a[last()]/@href")?.text {
                    print(href)
                    if href.contains("fid=") {
                        self.fid = href.components(separatedBy: "fid=")[1]
                        if self.fid == "125", !self.isNodeFid125 {
                            self.isNodeFid125 = true
                        }
                    }
                }
                if let text = html.at_xpath("//div[@id='f_pst']/form/@action")?.text {
                    action = text
                }
                if let text = html.at_xpath("//td[@class='plc ptm pbn vwthd']/h1/span")?.text {
                    header.title = text
                }
                if let text1 = html.at_xpath("//td[@class='plc ptm pbn vwthd']/div[@class='ptn']/span[2]")?.text, let text2 = html.at_xpath("//td[@class='plc ptm pbn vwthd']/div[@class='ptn']/span[5]")?.text {
                    header.commentCount = "查看: \(text1)  |  回复: \(text2)  |  tid(\(tid))"
                }
                if let href = html.at_xpath("//div[@class='bm cl']/div[@class='z']/a[3]/@href")?.text, href.contains("gid=") {
                    print(href)
                    header.gid = href.components(separatedBy: "gid=")[1]
                }
                if let text = html.at_xpath("//div[@class='bm cl']/div[@class='z']/a[3]")?.text {
                    header.indexTitle = text
                }
                if let forum = html.at_xpath("//div[@class='bm cl']/div[@class='z']/a[4]/@href")?.text {
                    if forum.contains("forum-") {
                        let id = forum.components(separatedBy: "forum-")[1].components(separatedBy: "-")[0]
                        header.nodeFid = id
                    } else if forum.contains("fid=") {
                        header.nodeFid = forum.components(separatedBy: "fid=")[1]
                    }
                }
                if let text = html.at_xpath("//div[@class='bm cl']/div[@class='z']/a[4]")?.text {
                    header.nodeTitle = text
                }
                if let text = html.toXML, text.contains("下一页") {
                    nextPage = true
                } else {
                    nextPage = false
                }
                if var size = html.at_xpath("//div[@class='pgs mtm mbm cl']/div[@class='pg']/a[last()-1]")?.text {
                    size = size.replacingOccurrences(of: "... ", with: "")
                    if let num = Int(size), num > 1 {
                        header.pageSize = num
                    }
                }
                if page == 1 {
                    let span = html.xpath("//span[@class='tag iconfont icon-tag-fill']/a")
                    var tags = [TagItemModel]()
                    span.forEach { e in
                        var tag = TagItemModel()
                        if let text = e.at_xpath("/@title")?.text {
                            tag.title = text
                        }
                        if let href = e.at_xpath("/@href")?.text, href.contains("id=") {
                            tag.tid = href.components(separatedBy: "id=")[1]
                        }
                        tags.append(tag)
                    }
                    header.tagItems = tags
                }
                let node = html.xpath("//table[@class='plhin']")
                var list = [TopicCommentModel]()
                node.forEach { element in
                    var comment = TopicCommentModel()
                    if let url = element.at_xpath("//div[@class='imicn']/a/@href")?.text {
                        let uid = url.getUid()
                        if !uid.isEmpty {
                            comment.uid = uid
                        }
                    }
                    if let avatar = element.at_xpath("//div[@class='avatar']//img/@src")?.text {
                        comment.avatar = avatar
                    }
                    if let name = element.at_xpath("//div[@class='authi']/a")?.text {
                        comment.name = name
                    }
                    if let time = element.at_xpath("//div[@class='authi']/em")?.text {
                        comment.time = time
                    }
                    let a = element.xpath("//div[@class='pob cl']//a")
                    a.forEach { ele in
                        if let text = ele.text, text.contains("回复") {
                            if let reply = ele.at_xpath("/@href")?.text {
                                comment.reply = reply
                            }
                        }
                    }
                    var table = element.at_xpath("//div[@class='t_fsz']/table")
                    if table?.toHTML == nil {
                        table = element.at_xpath("//div[@class='pcbs']/table")
                    }
                    if table?.toHTML == nil {
                        table = element.at_xpath("//div[@class='pcbs']")
                    }
                    let pattl = element.at_xpath("//div[@class='t_fsz']/div[@class='pattl']")
                    if pattl != nil {
                        table = element.at_xpath("//div[@class='t_fsz']")
                    }
                    if let content = table?.toHTML {
                        if let id = table?.at_xpath("//td/@id")?.text, id.contains("_") {
                            comment.pid = id.components(separatedBy: "_")[1]
                        }
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
                        if let action = element.at_xpath("//div[@class='pob cl']//a[1]/@href")?.text, action.contains("favorite") {
                            comment.favorite = action
                        }
                    }
                    list.append(comment)
                }
                html.getFormhash()

                if isSelectedPage {
                    comments = []
                }
                if page == 1 {
                    comments = list
                } else {
                    comments += list
                }
                isProgressViewHidden = true

                shieldUsers()
            }
        }
    }

    private func favorite() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/\(favoriteAction)")!
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.httpMethod = "POST"
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let text = html.toHTML {
                    if text.contains("信息收藏成功") {
                        hud.show(message: "收藏成功")
                    } else if text.contains("已收藏") {
                        hud.show(message: "抱歉，您已收藏，请勿重复收藏")
                    } else {
                        hud.show(message: "收藏收藏失败，请稍后重试")
                    }
                }
            } else {
                hud.show(message: "收藏收藏失败，请稍后重试")
            }
        }
    }

    private func comment() async {
        if inputComment.isEmpty {
            hud.show(message: "请输入评论内容")
            return
        }

        Task {
            if !UserInfo.shared.isLogin() {
                needLogin.toggle()
                return
            }

            isShowing = true
            let time = Int(Date().timeIntervalSince1970)
            // swiftlint:disable force_unwrapping
            let parames = "&formhash=\(UserInfo.shared.formhash)&message=\(inputComment)&posttime=\(time)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let url = URL(string: "https://www.chongbuluo.com/\(action)\(parames)")!
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
                closeDialog()
                await loadData()
            }
            isShowing = false
        }
    }

    private func getReply() async {
        if replyContent.isEmpty {
            hud.show(message: "请输入回复内容")
            return
        }

        Task {
            isShowingReply = true
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/\(replyAction)")!
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.httpMethod = "POST"
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                html.getFormhash()
                let time = Int(Date().timeIntervalSince1970)
                var param = "&formhash=\(UserInfo.shared.formhash)&message=\(replyContent)&posttime=\(time)&checkbox=0&wysiwyg=0&replysubmit=yes"
                if let noticeauthor = html.at_xpath("//input[@name='noticeauthor']/@value")?.text {
                    param += "&noticeauthor=\(noticeauthor)"
                }
                // FIXME: 回复暂时缺少跳转链接 [url=forum.php?mod=redirect&goto=findpost&pid=id&ptid=id]
                if var noticetrimstr = html.at_xpath("//input[@name='noticetrimstr']/@value")?.text,
                   noticetrimstr.contains("[url=") {
                    noticetrimstr = noticetrimstr.components(separatedBy: "[color=#999999]")[1]
                    let list = noticetrimstr.components(separatedBy: "[/color][/url][/size]\n")
                    let post_reply_quote = list[0]
                    let message = list[1].components(separatedBy: "[/quote]")[0]
                    noticetrimstr = "[quote][size=2][color=#999999]\(post_reply_quote)[/color][/size]\n\(message)[/quote]"
                    print(noticetrimstr)
                    /*
                     [quote][size=2][url=forum.php?mod=redirect&goto=findpost&pid=155892&ptid=11726][color=#999999]逍遥叹 发表于 2022-1-14 16:31[/color][/url][/size]
                     有app确实会更加方便一些，手机网页端说实话就是用来签下道。[/quote]
                     */
                    /*
                     if(!defined('IN_MOBILE')) {
                     $message = "[quote][size=2][url=forum.php?mod=redirect&goto=findpost&pid=$_GET[repquote]&ptid={$_G['tid']}][color=#999999]{$post_reply_quote}[/color][/url][/size]\n{$message}[/quote]";
                     } else {
                     $message = "[quote][color=#999999]{$post_reply_quote}[/color]\n[color=#999999]{$message}[/color][/quote]";
                     }
                     */
                    /*
                     <div class="quote"><blockquote><font size="2"><a href="https://www.chongbuluo.com/forum.php?mod=redirect&amp;goto=findpost&amp;pid=158920&amp;ptid=11916" target="_blank"><font color="#999999">Nullptr 发表于 2022-2-15 14:33</font></a></font><br />
                     请问老哥用什么工具订阅的呢</blockquote></div><br />
                     */
                    param += "&noticetrimstr=\(noticetrimstr)"
                    print(noticetrimstr)
                }
                if let noticeauthormsg = html.at_xpath("//input[@name='noticeauthormsg']/@value")?.text {
                    param += "&noticeauthormsg=\(noticeauthormsg)"
                }
                if let reppid = html.at_xpath("//input[@name='reppid']/@value")?.text {
                    param += "&reppid=\(reppid)"
                }
                if let reppost = html.at_xpath("//input[@name='reppost']/@value")?.text {
                    param += "&reppost=\(reppost)"
                }
                param = param.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                await reply(param)
            }
            isShowingReply = false
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
            //            requset.setValue("https://www.chongbuluo.com", forHTTPHeaderField: "Origin")
            //            requset.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            //            requset.setValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
            //            requset.setValue("navigate", forHTTPHeaderField: "Sec-Fetch-Mode")
            //            requset.setValue("?1", forHTTPHeaderField: "Sec-Fetch-User")
            //            requset.setValue("document", forHTTPHeaderField: "Sec-Fetch-Dest")
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let text = html.toHTML, text.contains("刚刚") || text.contains("秒前") {
                    replyContent = ""
                    hud.show(message: "回复成功")
                } else {
                    hud.show(message: "回复失败")
                }
                closeDialog()
                await loadData()
            }
        }
    }

    private func report() async {
        Task {
            let action = "misc.php?mod=report&rtype=post&tid=\(tid)"
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/\(action)")!
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.httpMethod = "POST"
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                print(html)
                hud.show(message: "感谢您的举报，管理员会对改帖子内容进行审核！")
            }
        }
    }

    private func handler(url: URL) {
        var absoluteString = url.absoluteString
        if absoluteString.contains("uid=") && !absoluteString.hasPrefix("http") {
            absoluteString = "https://www.chongbuluo.com/" + absoluteString
        }
        print(absoluteString)
        if absoluteString.contains("chongbuluo"), absoluteString.contains("thread") || absoluteString.contains("uid=") {
            // 帖子 个人空间
            if absoluteString.contains("uid=") {
                let uid = absoluteString.getUid()
                if !uid.isEmpty {
                    if uid == UserInfo.shared.uid {
                        selection.index = .mine
                        CacheInfo.shared.selectedTab = .mine
                    } else {
                        self.uid = uid
                        isSpace.toggle()
                    }
                }
            } else {
                if absoluteString.contains("&tid=") {
                    let list = absoluteString.components(separatedBy: "&")
                    var tid = ""
                    list.forEach { text in
                        if text.hasPrefix("tid=") {
                            tid = text
                        }
                    }
                    let tids = tid.components(separatedBy: "=")
                    if tids.count == 2 {
                        newTid = tids[1]
                        isViewthread.toggle()
                    }
                } else if absoluteString.contains("thread-") {
                    let tids = absoluteString.components(separatedBy: "thread-")
                    if tids.count == 2 {
                        newTid = tids[1].components(separatedBy: "-")[0]
                        isViewthread.toggle()
                    }
                }
            }
        } else if absoluteString.contains("chongbuluo") {
            // 签到 排行 积分 通知
            if absoluteString.contains("ac=daysign") {
                isDaysign.toggle()
            } else if absoluteString.contains("mod=ranklist") {
                isRanklist.toggle()
            } else if absoluteString.contains("ac=credit") {
                if UserInfo.shared.isLogin() {
                    isCredit.toggle()
                } else {
                    needLogin.toggle()
                }
            } else if absoluteString.contains("do=notice") {
                CacheInfo.shared.selectedTab = .notice
                selection.index = .notice
            }
        } else if absoluteString.hasPrefix("mailto:") {
            // 邮件
            UIApplication.shared.open(url)
        } else {
            // 打开 Safari
            webURLItem = WebURLItem(url: absoluteString)
        }
    }
}

struct TopicDetailContentView_Previews: PreviewProvider {
    static var previews: some View {
        TopicDetailContentView()
    }
}
