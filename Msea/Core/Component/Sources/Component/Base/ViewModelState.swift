//
//  ViewModelState.swift
//  Msea
//
//  Created by taozongqiang on 2025/4/24.
//  Copyright © 2025 eternal.just. All rights reserved.
//

import Foundation

/// ViewModel 状态
public protocol ViewModelState {
    /// 是否提示
    var isToast: Bool { get }
    /// 提示文本
    var toastMessage: String { get }

    /// 加载转圈
    var isLoading: Bool { get }
    /// 加载数据
    func loadData() async
}

extension ViewModelState {
    func loadData() async {
        print("ViewModel loadData ...")
    }
}
