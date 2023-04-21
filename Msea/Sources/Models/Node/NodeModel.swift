//
//  NodeModel.swift
//  Msea
//
//  Created by tzqiang on 2023/4/21.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

struct NodeListModel: Identifiable {
    var id = UUID()
    var fid = ""
    var tid = ""
    var title = ""
    var today = ""
    var count = ""
    var content = ""
    var time = ""
    var username = ""
    var icon: String {
        switch fid {
        case "2": return "laptopcomputer"
        case "44": return "key"
        case "47": return "square.grid.3x3.bottomleft.filled"
        case "93": return "plus.magnifyingglass"
        case "98": return "w.circle"
        case "112": return "yensign.circle"
        case "113": return "lightbulb"
        case "114": return "icloud.and.arrow.down"
        case "117": return "list.bullet.rectangle.portrait"
        case "119": return "eye"
        case "120": return "sun.max"
        case "121": return "building"
        case "122": return "highlighter"
        case "123": return "arrow.up.heart"
        case "125": return "eye.slash"
        case "126": return "g.circle"
        case "127": return "applelogo"
        case "128": return "gyroscope"
        case "130": return "network"
        default: return "yensign.circle"
        }
    }
}

struct NodeModel: Identifiable {
    var id = UUID()
    var title = ""
    var moderators = [String]()
    var list = [NodeListModel]()
}

struct NodeWikiLanguagePlantFieldModel: Identifiable {
    var id = UUID()
    var wiki = "all"
    var title = "不限"
}

struct NodeWikiListModel: Identifiable {
    var id = UUID()
    var uid = ""
    var name = ""
    var avatar = ""
    var comment = ""
    var views = ""
    var tid = ""
    var title = ""
    var bannerImage = ""
}
