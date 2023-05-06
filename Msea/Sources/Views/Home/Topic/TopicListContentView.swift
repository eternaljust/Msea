//
//  TopicListContentView.swift
//  Msea
//
//  Created by Awro on 2021/12/4.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 主题列表
struct TopicListContentView: View {
    let topicData: TopicListTabModel

    @State private var isSpace = false
    @State private var isTopic = false

    @EnvironmentObject private var store: AppStore

    var body: some View {
        ZStack {
            topicList

            progressView

            navigaitionLink
        }
        .onReceive(NotificationCenter.default.publisher(for: .shieldUser, object: nil)) { _ in
            Task {
                await store.dispatch(.topic(action: .shieldUsers))
            }
        }
        .onChange(of: isSpace) { newValue in
            if UIDevice.current.isPad && newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isSpace.toggle()
                }
            }
        }
        .onChange(of: isTopic) { newValue in
            if UIDevice.current.isPad && newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTopic.toggle()
                }
            }
        }
    }

    var topicList: some View {
        List(topicData.topics) { topic in
            TopicListItemRow(topic: topic, avatarClick: {
                navigateToProfileSpace(topic.uid)
            })
            .padding([.top, .bottom], 5)
            .onAppear {
                if topic.id == topicData.topics.last?.id {
                    loadListData()
                }
            }
            .onTapGesture(perform: {
                if !topic.tid.isEmpty {
                    navigateToTopicDetail(topic.tid)
                }
            })
        }
        .listStyle(.plain)
        .refreshable {
            Task {
                await store.dispatch(.topic(action: .resetPage(topicData.tab)))
                await store.dispatch(.topic(action: .loadList(tab: topicData.tab, page: topicData.page)))
            }
        }
        .task {
            if !topicData.isProgressHidden {
                await store.dispatch(.topic(action: .loadList(tab: topicData.tab, page: topicData.page)))
            }
        }
    }

    var progressView: some View {
        ProgressView()
            .isHidden(topicData.isProgressHidden)
    }

    var navigaitionLink: some View {
        ZStack {
            NavigationLink(destination: SpaceProfileContentView(uid: store.state.topic.uid), isActive: $isSpace) {
                EmptyView()
            }
            .opacity(0.0)

            NavigationLink(destination: TopicDetailContentView(tid: store.state.topic.tid), isActive: $isTopic) {
                EmptyView()
            }
            .opacity(0.0)
        }
    }
}

extension TopicListContentView {
    private func loadListData() {
        Task {
            await store.dispatch(.topic(action: .pageAdd(topicData.tab)))
            await store.dispatch(.topic(action: .loadList(tab: topicData.tab, page: topicData.page)))
        }
    }

    private func navigateToProfileSpace(_ uid: String) {
        Task {
            await store.dispatch(.topic(action: .setUid(uid)))
            isSpace.toggle()
        }
    }

    private func navigateToTopicDetail(_ tid: String) {
        Task {
            await store.dispatch(.topic(action: .setTid(tid)))
            isTopic.toggle()
        }
    }
}

struct TopicListItemRow: View {
    let topic: TopicListModel
    let avatarClick: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                HStack {
                    AsyncImage(url: URL(string: "https://www.chongbuluo.com/\(topic.avatar)")) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 40, height: 40)
                    .cornerRadius(5)
                    .onTapGesture(perform: {
                        if !topic.uid.isEmpty {
                            avatarClick()
                        }
                    })

                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(topic.name)
                                .font(.font17Blod)
                                .onTapGesture(perform: {
                                    if !topic.uid.isEmpty {
                                        avatarClick()
                                    }
                                })

                            Spacer()

                            Text("\(topic.reply)/\(topic.examine)")
                                .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                                .foregroundColor(.white)
                                .background(
                                    Capsule()
                                        .foregroundColor(.secondaryTheme.opacity(0.8))
                                )
                        }

                        HStack {
                            Text(topic.time)
                                .font(.font13)

                            if !topic.icon1.isEmpty {
                                Image(systemName: topic.icon1)
                                    .foregroundColor(getColor(topic.icon1))
                            }

                            if !topic.icon2.isEmpty {
                                Image(systemName: topic.icon2)
                                    .foregroundColor(getColor(topic.icon2))
                            }

                            if !topic.icon3.isEmpty {
                                Image(systemName: topic.icon3)
                                    .foregroundColor(getColor(topic.icon3))
                            }

                            if !topic.icon4.isEmpty {
                                Image(systemName: topic.icon4)
                                    .foregroundColor(getColor(topic.icon4))
                            }
                        }
                    }
                }
            }

            Text("\(topic.title)\(Text(topic.attachment).foregroundColor(topic.attachmentColorRed ? .red : Color(light: .black, dark: .white)))")
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func getColor(_ icon: String) -> Color {
        if icon == "photo" {
            return .theme
        } else if icon == "flame" {
            return .red
        } else if icon == "hands.sparkles" {
            return .secondaryTheme
        } else if icon == "link" {
            return .blue
        } else if icon == "rosette" {
            return .brown
        }
        return .theme
    }
}

struct TopicListContentView_Previews: PreviewProvider {
    static var previews: some View {
        TopicListContentView(topicData: TopicListTabModel(tab: .new))
    }
}
