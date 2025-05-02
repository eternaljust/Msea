//
//  MineModel.swift
//  Msea
//
//  Created by tzqiang on 2023/4/21.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

enum LoginField: String, CaseIterable, Identifiable {
    case username
    case email

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .username:
            return "person.circle"
        case .email:
            return "envelope"
        }
    }

    var title: String {
        switch self {
        case .username:
            return "用户名"
        case .email:
            return "邮箱"
        }
    }

    var placeholder: String {
        switch self {
        case .username:
            return "输入用户名"
        case .email:
            return "输入邮箱"
        }
    }
}

enum LoginQuestion: String, CaseIterable, Identifiable {
    case no
    case mothername
    case grandpaname
    case fatherborncity
    case oneteachername
    case computermodel
    case favoriterestaurantname
    case lastfourdigitsofdriverlicense

    var id: String { self.rawValue }

    var qid: String {
        switch self {
        case .no:
            return "0"
        case .mothername:
            return "1"
        case .grandpaname:
            return "2"
        case .fatherborncity:
            return "3"
        case .oneteachername:
            return "4"
        case .computermodel:
            return "5"
        case .favoriterestaurantname:
            return "6"
        case .lastfourdigitsofdriverlicense:
            return "7"
        }
    }

    var icon: String {
        switch self {
        case .no:
            return "eye.slash"
        case .mothername:
            return "person.crop.square"
        case .grandpaname:
            return "person.crop.circle"
        case .fatherborncity:
            return "building.2"
        case .oneteachername:
            return "graduationcap"
        case .computermodel:
            return "desktopcomputer"
        case .favoriterestaurantname:
            return "fork.knife"
        case .lastfourdigitsofdriverlicense:
            return "123.rectangle"
        }
    }

    var title: String {
        switch self {
        case .no:
            return "未设置请忽略"
        case .mothername:
            return "母亲的名字"
        case .grandpaname:
            return "爷爷的名字"
        case .fatherborncity:
            return "父亲出生的城市"
        case .oneteachername:
            return "您其中一位老师的名字"
        case .computermodel:
            return "您个人计算机的型号"
        case .favoriterestaurantname:
            return "您最喜欢的餐馆名称"
        case .lastfourdigitsofdriverlicense:
            return "驾驶执照最后四位数字"
        }
    }
}

struct MyVisitorTraceModel: Identifiable {
    var id = UUID()
    var name = ""
    var uid = ""
    var avatar = ""
    var time = ""
    var topic = ""
}

struct MessageBoardListModel: Identifiable {
    var id = UUID()
    var uid = ""
    var name = ""
    var avatar = ""
    var comment = ""
    var replyName = ""
    var quote = ""
    var time = ""
    var gifURL = ""
    var gifLeft = true
    var quoteGifURL = ""
    var quoteGifLeft = true
}

struct FavoritePostModel: Identifiable {
    var id = UUID()
    var tid = ""
    var time = ""
    var title = ""
    var action = ""
}

struct PostboxTypeModel: Identifiable {
    var id = UUID()
    var typeid = "0"
    var title = ""
}
