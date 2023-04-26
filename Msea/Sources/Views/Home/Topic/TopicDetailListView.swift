//
//  TopicDetailListView.swift
//  Msea
//
//  Created by tzqiang on 2023/4/26.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import SwiftUI

struct TopicDetailListItemRow<T>: View where T : View {
    let comment: TopicCommentModel
    let isNodeFid125: Bool
    let avatarClick: () -> Void
    @ViewBuilder
    let webContent: () -> T

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                AsyncImage(url: URL(string: comment.avatar)) { image in
                    image
                        .resizable()
                        .overlay {
                            if isNodeFid125 {
                                Color.gray.opacity(0.9)
                            }
                        }
                } placeholder: {
                    if isNodeFid125 {
                        Color.gray.opacity(0.9)
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 40, height: 40)
                .cornerRadius(5)

                VStack(alignment: .leading, spacing: 5) {
                    Text(comment.name)
                        .font(.font17Blod)

                    Text(comment.time)
                        .font(.font13)
                }
            }
            .onTapGesture {
                if !comment.uid.isEmpty {
                    avatarClick()
                }
            }

            if comment.isText {
                Text(comment.content)
                    .font(.font16)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(5)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                webContent()
            }
        }
    }
}

struct TopicDetailListHeader: View {
    @Binding var isConfirming: Bool

    let isNodeFid125: Bool
    let header: TopicListHeaderModel
    let nodeClick: () -> Void
    let indexClick: () -> Void
    let nodeListClick: () -> Void
    let tagClick: (String) -> Void
    let selectedPage: (Int) -> Void

    @EnvironmentObject private var hud: HUDState

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Image(systemName: "circle.grid.cross.fill")

                    Text("节点")
                        .onTapGesture {
                            nodeClick()
                        }

                    if !header.indexTitle.isEmpty && !header.gid.isEmpty {
                        Image(systemName: "chevron.right")

                        Text(header.indexTitle)
                            .onTapGesture {
                                indexClick()
                            }
                    }

                    if !header.nodeTitle.isEmpty && !header.nodeFid.isEmpty {
                        Image(systemName: "chevron.right")

                        Text(header.nodeTitle)
                            .onTapGesture {
                                nodeListClick()
                            }
                    }
                }
                .font(.font17)
                .foregroundColor(isNodeFid125 ? .gray : .secondaryTheme)

                Text(header.title)
                    .font(.font20)
                    .foregroundColor(Color(light: .black, dark: .white))
                    .onTapGesture {
                        UIPasteboard.general.string = header.tid
                        hud.show(message: "已复制 tid")
                    }

                Text(header.commentCount)

                if !header.tagItems.isEmpty {
                    HStack {
                        Image(systemName: "tag")
                            .foregroundColor(isNodeFid125 ? .gray : .secondaryTheme)

                        LazyHGrid(rows: [GridItem(.flexible())], alignment: .center) {
                            ForEach(header.tagItems) { t in
                                Text(t.title)
                                    .lineLimit(1)
                                    .padding(EdgeInsets(top: 3, leading: 7, bottom: 3, trailing: 7))
                                    .foregroundColor(.white)
                                    .background(
                                        Capsule()
                                            .foregroundColor((isNodeFid125 ? Color.gray : Color.secondaryTheme).opacity(0.8))
                                    )
                                    .onTapGesture {
                                        tagClick(t.tid)
                                    }
                            }
                        }
                    }
                }
            }

            if header.pageSize > 1 {
                Spacer()

                Button {
                    isConfirming.toggle()
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
                .confirmationDialog("", isPresented: $isConfirming) {
                    ForEach((1...header.pageSize), id: \.self) { index in
                        Button("\(index)") {
                            selectedPage(index)
                        }
                    }
                } message: {
                    Text("分页选择")
                }
            }
        }
    }
}
