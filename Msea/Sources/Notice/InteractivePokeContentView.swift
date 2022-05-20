//
//  InteractivePokeContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/5/19.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 坛友互动：打招呼
struct InteractivePokeContentView: View {
    private let type = InteractiveTab.poke

    @State private var page = 1
    @State private var pokeList = [InteractivePokeListModel]()
    @State private var isHidden = false
    @State private var isConfirming = false
    @State private var showAlert = false
    @State private var groupList = [PokeGroupModel]()
    @State private var selectedPoke = InteractivePokeListModel()
    @EnvironmentObject private var hud: HUDState

    @State private var uid = ""
    @State private var isSpace = false

    var body: some View {
        ZStack {
            if pokeList.isEmpty {
                Text("暂时没有提醒内容")
            } else {
                List(pokeList) { poke in
                    HStack {
                        AsyncImage(url: URL(string: poke.avatar)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 40, height: 40)
                        .cornerRadius(5)
                        .onTapGesture(perform: {
                            if !poke.uid.isEmpty {
                                uid = poke.uid
                                isSpace = true
                            }
                        })

                        VStack(alignment: .leading, spacing: 5) {
                            Text(poke.time)
                                .font(.font13)

                            HStack(alignment: .center, spacing: 5) {
                                Text(poke.name)
                                    .foregroundColor(.secondaryTheme)

                                if !poke.gif.isEmpty {
                                    GifImage(url: URL(string: poke.gif))
                                        .frame(width: 20, height: 20)
                                }

                                Text(poke.content)

                                Text(poke.action)
                                    .foregroundColor(.secondaryTheme)
                                    .onTapGesture(perform: {
                                        guard let url = URL(string: poke.actionURL), UIApplication.shared.canOpenURL(url) else { return }
                                        UIApplication.shared.open(url)
                                    })
                                    .confirmationDialog("", isPresented: $isConfirming) {
                                        ForEach(groupList) { group in
                                            Button {
                                                print(group.pid)
                                                Task {
                                                    await action("\(selectedPoke.actionURL)&poke=\(group.pid)&pokesubmit=true")
                                                }
                                            } label: {
                                                Text(group.name)
                                            }
                                        }
                                    } message: {
                                        Text("向 \(selectedPoke.name)  打个招呼:")
                                    }

                                Text(poke.ignore)
                                    .foregroundColor(.secondaryTheme)
                                    .onTapGesture(perform: {
                                        selectedPoke = poke
                                        showAlert = true
                                    })
                                    .alert("确定忽略招呼吗？", isPresented: $showAlert) {
                                        Button("取消", role: .cancel) {
                                        }

                                        Button("确定") {
                                            showAlert = false
                                            guard let url = URL(string: selectedPoke.ignoreURL), UIApplication.shared.canOpenURL(url) else { return }
                                            UIApplication.shared.open(url)
                                        }
                                    } message: {
                                    }
                            }
                            .font(.font16)
                        }
                        .padding([.top, .bottom], 5)
                        .onAppear {
                            if poke.id == pokeList.last?.id {
                                page += 1
                                Task {
                                    await loadData()
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    page = 1
                    await loadData()
                }
                .navigationTitle("坛友互动")
            }

            ProgressView()
                .isHidden(isHidden)

            NavigationLink(destination: SpaceProfileContentView(uid: uid), isActive: $isSpace) {
                EmptyView()
            }
            .opacity(0.0)
        }
        .task {
            if !isHidden {
                page = 1
                await loadData()
            }
        }
        .onOpenURL { url in
            print(url.absoluteString)
            if let poke = pokeList.first(where: { $0.actionURL == url.absoluteString }) {
                selectedPoke = poke
            }

            Task {
                await action(url.absoluteString)
            }
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=space&do=notice&view=interactive&type=\(type.rawValue)&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let dl = html.xpath("//dl[@class='cl ']")
                var list = [InteractivePokeListModel]()
                dl.forEach({ element in
                    var poke = InteractivePokeListModel()
                    if let time = element.at_xpath("//span[@class='xg1 xw0']")?.text {
                        poke.time = time
                    }
                    if let avatar = element.at_xpath("//dd[@class='m avt mbn']/a/img/@src")?.text {
                        poke.avatar = avatar.replacingOccurrences(of: "&size=small", with: "")
                    }
                    if let name = element.at_xpath("//dd[@class='ntc_body']/a[1]")?.text {
                        poke.name = name
                    }
                    if let uid = element.at_xpath("//dd[@class='ntc_body']/a[1]/@href")?.text,
                       uid.contains("uid=") {
                        poke.uid = uid.components(separatedBy: "uid=")[1]
                    }
                    if let text = element.at_xpath("//dd[@class='ntc_body']/a[2]")?.text {
                        poke.action = text
                    }
                    if let text = element.at_xpath("//dd[@class='ntc_body']/a[2]/@href")?.text {
                        poke.actionURL = "msea://" + text
                    }
                    if let text = element.at_xpath("//dd[@class='ntc_body']/a[last()]")?.text {
                        poke.ignore = text
                    }
                    if let text = element.at_xpath("//dd[@class='ntc_body']/a[last()]/@href")?.text {
                        poke.ignoreURL = "msea://" + text + "&ignoresubmit=true"
                    }
                    if let content = element.at_xpath("//dd[@class='ntc_body']/span[1]")?.text {
                        poke.content = content
                    }
                    if let gif = element.at_xpath("//dd[@class='ntc_body']/span[1]/img/@src")?.text, !gif.isEmpty {
                        poke.gif = "https://chongbuluo.com/" + gif
                    }
                    list.append(poke)
                })

                if page == 1 {
                    pokeList = list
                } else {
                    pokeList += list
                }
            }

            isHidden = true
        }
    }

    private func action(_ url: String) async {
        isHidden = false
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/\(url.replacingOccurrences(of: "msea://", with: ""))&formhash=\(UserInfo.shared.formhash)")!
            // swiftlint:enble force_unwrapping
            print(url.absoluteString)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let message = html.at_xpath("//div[@id='messagetext']/p")?.text, !message.isEmpty {
                    if message.contains("setTimeout") {
                        let text = message.components(separatedBy: "setTimeout")[0]
                        hud.show(message: text)
                    } else {
                        hud.show(message: message)
                    }

                    page = 1
                    await loadData()
                } else {
                    let lis = html.xpath("//ul[@class='poke cl']/li/label")
                    var list = [PokeGroupModel]()
                    lis.forEach { element in
                        var group = PokeGroupModel()
                        if let text = element.text {
                            group.name = text
                        }
                        if let text = element.at_xpath("/input/@value")?.text {
                            group.pid = text
                        }
                        if let text = element.at_xpath("/img/@src")?.text {
                            group.gif = "https://www.chongbuluo.com/" + text
                        }
                        list.append(group)
                    }

                    groupList = list
                    if !groupList.isEmpty {
                        isConfirming.toggle()
                    }
                }
            }

            isHidden = true
        }
    }
}

struct InteractivePokeContentView_Previews: PreviewProvider {
    static var previews: some View {
        InteractivePokeContentView()
    }
}

struct InteractivePokeListModel: Identifiable {
    var id = UUID()
    var uid = ""
    var avatar = ""
    var name = ""
    var time = ""
    var gif = ""
    var content = ""
    var action = ""
    var actionURL = ""
    var ignore = ""
    var ignoreURL = ""
}

struct PokeGroupModel: Identifiable {
    var id = UUID()
    var pid = ""
    var name = ""
    var gif = ""
}
