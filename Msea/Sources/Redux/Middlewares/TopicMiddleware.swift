//
//  TopicMiddleware.swift
//  Msea
//
//  Created by tzqiang on 2023/4/24.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation
import Combine
import Kanna

func topicMiddleware() -> Middleware<AppState, AppAction> {
    return { _, action in
        switch action {
        case let .topic(action: .loadList(tab: tab, page: page)):
            let url = "\(HTMLURL.topicList)&view=\(tab.id)&page=\(page)"
            return Network.instance.getRequset(url)
                .map {
                    let node = $0.xpath("//tbody")
                    var list = [TopicListModel]()
                    node.forEach { element in
                        var topic = TopicListModel()
                        if let avatar = element.at_xpath("//img//@src")?.text {
                            topic.avatar = avatar
                        }
                        if let name = element.at_xpath("//cite/a")?.text {
                            topic.name = name
                        }
                        if let title = element.at_xpath("//th/a[@class='xst']")?.text {
                            topic.title = title
                            if let name = element.at_xpath("//th[@class='common']/span[1]/@class")?.text {
                                topic.icon1 = getIcon(name)
                            }
                            if let name = element.at_xpath("//th[@class='common']/span[2]/@class")?.text {
                                topic.icon2 = getIcon(name)
                            }
                            if let name = element.at_xpath("//th[@class='common']/span[3]/@class")?.text {
                                topic.icon3 = getIcon(name)
                            }
                            if let name = element.at_xpath("//th[@class='common']/span[4]/@class")?.text {
                                topic.icon4 = getIcon(name)
                            }
                            if let text = element.at_xpath("//th[@class='common']/span[@class='xi1']")?.text, !text.isEmpty {
                                topic.attachment = text
                            } else if var text = element.at_xpath("//th[@class='common']")?.text, text.count != title.count {
                                text = text.replacingOccurrences(of: "\r\n", with: "")
                                var attachment = text.replacingOccurrences(of: title, with: "")
                                if let num = element.at_xpath("//th[@class='common']/span[@class='tps']")?.text {
                                    attachment = attachment.replacingOccurrences(of: num, with: "")
                                }
                                attachment = attachment.replacingOccurrences(of: " ", with: "")
                                topic.attachment = attachment
                            }
                            if !topic.attachment.isEmpty {
                                topic.attachment = topic.attachment.replacingOccurrences(of: "-", with: "")
                                topic.attachment = " - \(topic.attachment)"
                                topic.attachmentColorRed = topic.attachment.contains("回帖") || topic.attachment.contains("悬赏")
                            }
                            if let time = element.at_xpath("//td[@class='by']//span//@title")?.text {
                                topic.time = time
                            }
                            if let xi2 = element.at_xpath("//td/a[@class='xi2']")?.text, let reply = Int(xi2) {
                                topic.reply = reply
                            }
                            if let em = element.at_xpath("//td[@class='num']/em")?.text, let examine = Int(em) {
                                topic.examine = examine
                            }
                            if let uid = element.at_xpath("//cite/a//@href")?.text {
                                topic.uid = uid.getUid()
                            }
                            if let id = element.at_xpath("//@id")?.text, let tid = id.components(separatedBy: "_").last {
                                topic.tid = tid
                            }
                            list.append(topic)
                        }
                    }
                    $0.getFormhash()
                    list = list.filter { model in
                        !UserInfo.shared.shieldUsers.contains { $0.uid == model.uid }
                    }

                    return AppAction.topic(action: .loadListComplete(tab: tab, page: page, list: list))
                }
                .catch { (error: NetworkError) -> Just<AppAction> in
                    return Just(AppAction.topic(action: .loadDataError(error.localizedDescription)))
                }
                .eraseToAnyPublisher()
        default :
            break
        }
        return Empty().eraseToAnyPublisher()
    }
}

func getIcon(_ name: String) -> String {
    if name == "iconfont icon-image" {
        return "photo"
    } else if name == "iconfont icon-fire" {
        return "flame"
    } else if name == "iconfont icon-guzhang1" {
        return "hands.sparkles"
    } else if name == "iconfont icon-attachment1" {
        return "link"
    } else if name == "iconfont icon-jinghua" {
        return "rosette"
    }
    return ""
}
