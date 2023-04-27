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

    @EnvironmentObject private var store: AppStore

    var body: some View {
        ZStack {
            if disAgree || isPosterShielding {
                TopicDetailTipText(disAgree: disAgree)
            } else {
                VStack {
                    commentList

                    navigationLink
                }
            }

            progressView
        }
        .edgesIgnoringSafeArea(UIDevice.current.isPad ? [] : [.bottom])
        .navigationTitle("帖子详情")
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
            if let first = store.state.topicDetail.comments.first {
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
                    ForEach(store.state.topicDetail.comments) { comment in
                        TopicDetailListItemRow(
                            comment: comment,
                            isNodeFid125: store.state.topicDetail.detail.isNodeFid125,
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
                                    isNodeFid125: store.state.topicDetail.detail.isNodeFid125,
                                    didFinish: { scrollHeight in
                                        if comment.webViewHeight == .zero,
                                           let index = store.state.topicDetail.comments.firstIndex(
                                            where: { obj in obj.id == comment.id }) {
                                            var model = comment
                                            model.webViewHeight = scrollHeight
                                            model.id = UUID()
                                            Task {
                                                if index < store.state.topicDetail.comments.count, store.state.topicDetail.comments.count != 1 {
                                                    var comments = store.state.topicDetail.comments
                                                    comments.replaceSubrange(index..<(index + 1), with: [model])
                                                    await store.dispatch(.topicDetail(action: .replaceList(comments)))
                                                } else {
                                                    await store.dispatch(.topicDetail(action: .replaceList([model])))
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
                            if comment.id == store.state.topicDetail.comments.last?.id {
                                if store.state.topicDetail.detail.nextPage {
                                    Task {
                                        await store.dispatch(.topicDetail(action: .pageAdd))
                                        await loadData()
                                    }
                                }
                            }
                        }
                        .swipeActions {
                            if !store.state.topicDetail.detail.isNodeFid125 {
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
                        isNodeFid125: store.state.topicDetail.detail.isNodeFid125,
                        header: store.state.topicDetail.header,
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
                                await store.dispatch(.topicDetail(action: .setTagId(id)))
                                isTag.toggle()
                            }
                        },
                        selectedPage: { index in
                            Task {
                                await store.dispatch(.topicDetail(action: .selectedPage(index)))
                                await store.dispatch(.topicDetail(action: .loadList(tid: tid)))
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
                if !store.state.topicDetail.detail.isProgressViewHidden {
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
                TopicDetailBottomButton(isNodeFid125: store.state.topicDetail.detail.isNodeFid125) {
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
            .isHidden(store.state.topicDetail.detail.isProgressViewHidden)
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
                    if let action = store.state.topicDetail.comments.first?.favorite,
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

    var navigationLink: some View {
        ZStack {
            NavigationLink(destination: SpaceProfileContentView(uid: uid), isActive: $isSpace) {
                EmptyView()
            }
            .opacity(0.0)

            NavigationLink(destination: TopicDetailContentView(tid: newTid), isActive: $isViewthread) {
                EmptyView()
            }
            .opacity(0.0)

            NavigationLink(destination: DaySignContentView(), isActive: $isDaysign) {
                EmptyView()
            }
            .opacity(0.0)

            NavigationLink(destination: MyCreditContentView(), isActive: $isCredit) {
                EmptyView()
            }
            .opacity(0.0)

            NavigationLink(destination: RankListContentView(), isActive: $isRanklist) {
                EmptyView()
            }
            .opacity(0.0)

            NavigationLink(destination: NodeContentView(gid: store.state.topicDetail.header.gid), isActive: $isNode) {
                EmptyView()
            }
            .opacity(0.0)

            NavigationLink(destination: NodeListContentView(nodeTitle: store.state.topicDetail.header.nodeTitle, nodeFid: store.state.topicDetail.header.nodeFid), isActive: $isNodeList) {
                EmptyView()
            }
            .opacity(0.0)

            NavigationLink(destination: TagListContentView(id: store.state.topicDetail.header.tagId, searchState: SearchState()), isActive: $isTag) {
                EmptyView()
            }
            .opacity(0.0)
        }
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
                    .onChange(of: inputComment) { newValue in
                        print(newValue)
                    }
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
                    .onChange(of: replyContent) { newValue in
                        print(newValue)
                    }
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
        Task {
            await store.dispatch(.topicDetail(action: .shieldUsers))
        }
    }

    private func reloadData() async {
        await store.dispatch(.topicDetail(action: .resetPage))
        await store.dispatch(.topicDetail(action: .loadList(tid: tid)))
    }

    private func loadData() async {
        await store.dispatch(.topicDetail(action: .pageAdd))
        await store.dispatch(.topicDetail(action: .loadList(tid: tid)))
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
            let url = URL(string: "https://www.chongbuluo.com/\(store.state.topicDetail.detail.action)\(parames)")!
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
