//
//  ShieldUserContentView.swift
//  Msea
//
//  Created by Awro on 2022/1/30.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI

/// 屏蔽列表
struct ShieldUserContentView: View {
    @State private var shieldUsers = UserInfo.shared.shieldUsers

    var body: some View {
        VStack {
            if UserInfo.shared.shieldUsers.isEmpty {
                Text("暂无屏蔽的用户")
            } else {
                List {
                    Section {
                        ForEach(shieldUsers) { user in
                            NavigationLink(destination: SpaceProfileContentView(uid: user.uid)) {
                                HStack {
                                    AsyncImage(url: URL(string: user.avatar)) { image in
                                        image.resizable()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 45, height: 45)
                                    .cornerRadius(5)

                                    Text(user.name)
                                        .font(.font15)
                                }
                            }
                        }
                    } header: {
                        Text("已屏蔽用户(\(UserInfo.shared.shieldUsers.count) 个)")
                    }
                }
            }
        }
        .navigationBarTitle("屏蔽")
        .onAppear {
            shieldUsers = UserInfo.shared.shieldUsers
        }
        .onReceive(NotificationCenter.default.publisher(for: .shieldUser, object: nil)) { _ in
            shieldUsers = UserInfo.shared.shieldUsers
        }
    }
}

struct ShieldUserContentView_Previews: PreviewProvider {
    static var previews: some View {
        ShieldUserContentView()
    }
}
