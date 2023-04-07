//
//  String+Extension.swift
//  Msea
//
//  Created by tzqiang on 2023/4/7.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

extension String {
    /// 截取到任意位置
    func subString(to: Int) -> String {
        let offsetBy = to > self.count ? self.count : to
        let index: String.Index = self.index(startIndex, offsetBy: offsetBy < 0 ? 0 : offsetBy)
        return String(self[..<index])
    }
    /// 从任意位置开始截取
    func subString(from: Int) -> String {
        let offsetBy = from > self.count ? self.count : from
        let index: String.Index = self.index(startIndex, offsetBy: offsetBy < 0 ? 0 : offsetBy)
        return String(self[index ..< endIndex])
    }
    /// 从任意位置开始截取到任意位置
    func subString(from: Int, to: Int) -> String {
        let startOffsetBy = from > self.count ? self.count : from
        let endOffsetBy = to > self.count ? self.count : to
        let beginIndex = self.index(self.startIndex, offsetBy: startOffsetBy < 0 ? 0 : startOffsetBy)
        let endIndex = self.index(self.startIndex, offsetBy: endOffsetBy < 0 ? 0 : endOffsetBy)
        if startOffsetBy <= endOffsetBy {
            return String(self[beginIndex...endIndex])
        }
        return String(self[endIndex...beginIndex])
    }
}
