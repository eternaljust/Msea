//
//  TopicDetailMiddleware.swift
//  Msea
//
//  Created by tzqiang on 2023/4/27.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation
import Combine

func topicDetailMiddleware() -> Middleware<AppState, AppAction> {
    return { state, action in
        switch action {
        case .topicDetail(action: .loadList(let tid)):
            print("loadList tid = \(tid)")
            print("state.topicDetail.detail.page=\(state.topicDetail.detail.page)")
            let url = "\(HTMLURL.topicDetail)-\(tid)-\(state.topicDetail.detail.page)-1.html"
            return Network.instance.getRequset(url)
                .map { html in
                    var header = state.topicDetail.header
                    var detail = state.topicDetail.detail
                    header.tid = tid
                    if let href = html.at_xpath("//div[@class='bm cl']/div[@class='z']/a[last()]/@href")?.text {
                        print(href)
                        if href.contains("fid=") {
                            detail.fid = href.components(separatedBy: "fid=")[1]
                            if detail.fid == "125" {
                                detail.isNodeFid125 = true
                            }
                        }
                    }
                    if let text = html.at_xpath("//div[@id='f_pst']/form/@action")?.text {
                        detail.action = text
                    }
                    if let text = html.at_xpath("//td[@class='plc ptm pbn vwthd']/h1/span")?.text {
                        header.title = text
                    }
                    if let text1 = html.at_xpath("//td[@class='plc ptm pbn vwthd']/div[@class='ptn']/span[2]")?.text, let text2 = html.at_xpath("//td[@class='plc ptm pbn vwthd']/div[@class='ptn']/span[5]")?.text {
                        header.commentCount = "查看: \(text1)  |  回复: \(text2)  |  tid(\(tid))"
                    }
                    if let href = html.at_xpath("//div[@class='bm cl']/div[@class='z']/a[3]/@href")?.text, href.contains("gid=") {
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
                    if let text = html.toHTML, text.contains("下一页") {
                        detail.nextPage = true
                    } else {
                        detail.nextPage = false
                    }
                    if var size = html.at_xpath("//div[@class='pgs mtm mbm cl']/div[@class='pg']/a[last()-1]")?.text {
                        size = size.replacingOccurrences(of: "... ", with: "")
                        if let num = Int(size), num > 1 {
                            header.pageSize = num
                        }
                    }
                    if state.topicDetail.detail.page == 1 {
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
                    list = list.filter { model in
                        !UserInfo.shared.shieldUsers.contains { $0.uid == model.uid }
                    }
                    detail.isProgressViewHidden = true

                    return AppAction.topicDetail(action: .loadListComplete(header: header, detail: detail, list: list))
                }
                .catch { (error: NetworkError) -> Just<AppAction> in
                    return Just(AppAction.topicDetail(action: .loadDataError(error.localizedDescription)))
                }
                .eraseToAnyPublisher()
        default :
            break
        }
        return Empty().eraseToAnyPublisher()
    }
}
