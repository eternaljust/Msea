//
//  ProfileModel.swift
//  Msea
//
//  Created by tzqiang on 2023/4/21.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

struct ProfileModel {
    var uid = ""
    var space = ""
    var level = ""
    var name = ""
    var avatar = ""
    var views = "0"
    var integral = "--"
    var bits = "--"
    var friend = "--"
    var topic = "--"
    var violation = "--"
    var blog = "--"
    var album = "--"
    var share = "--"
    var reply = "--"
}

struct ShieldUserModel: Codable, Identifiable {
    var id = UUID().uuidString
    var uid = ""
    var name = ""
    var avatar = ""
}

struct ProfileTopicListModel: Identifiable {
    var id = UUID()
    var uid = ""
    var fid = ""
    var title = ""
    var tid = ""
    var gif = ""
    var plate = ""
    var name = ""
    var time = ""
    var examine = 0
    var reply = 0
}
