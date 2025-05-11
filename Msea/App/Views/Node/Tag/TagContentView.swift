//
//  TagContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/3/29.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna
import EJExtension
import IHome

/// 标签网格
struct TagContentView: View {
    @State private var tagItems = [TagItemModel]()
    @State private var isHidden = false
    @State private var isSearch = false

    @State private var tagId = ""
    @State private var isTag = false

    var body: some View {
        VStack {
            ZStack {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 110, maximum: 200))], alignment: .center, spacing: 10) {
                        ForEach(tagItems) { t in
                            Text(t.title)
                                .lineLimit(1)
                                .padding(EdgeInsets(top: 3, leading: 7, bottom: 3, trailing: 7))
                                .foregroundColor(.white)
                                .background(
                                    Capsule()
                                        .foregroundColor(.secondaryTheme.opacity(0.8))
                                )
                                .onTapGesture {
                                    tagId = t.tid
                                    isTag.toggle()
                                }
                        }
                    }
                }
                .padding([.leading, .trailing], 10)
                .refreshable {
                    Task {
                        await loadData()
                    }
                }
                .task {
                    if !isHidden {
                        await loadData()
                    }
                }

                ProgressView()
                    .isHidden(isHidden)
            }
        }
        .navigationTitle("标签")
        .navigationDestination(isPresented: $isSearch, destination: {
            TagSearchContentView()
        })
        .navigationDestination(isPresented: $isTag, destination: {
            TagListContentView(id: tagId, searchState: SearchState())
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isSearch.toggle()
                } label: {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
        .onAppear(perform: {
            TabBarTool.showTabBar(false)
        })
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/misc.php?mod=tag")!
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let div = html.xpath("//div[@class='taglist mtm mbm']/a")
                var tags = [TagItemModel]()
                div.forEach { element in
                    var tag = TagItemModel()
                    if let text = element.at_xpath("/@title")?.text {
                        tag.title = text
                    }
                    if let href = element.at_xpath("/@href")?.text, href.contains("id=") {
                        tag.tid = href.components(separatedBy: "id=")[1]
                    }
                    tags.append(tag)
                }
                tagItems = tags
                isHidden = true
            }
        }
    }
}

struct TagContentView_Previews: PreviewProvider {
    static var previews: some View {
        TagContentView()
    }
}
