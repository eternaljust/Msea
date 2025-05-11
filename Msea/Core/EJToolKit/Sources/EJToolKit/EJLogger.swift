//
//  File.swift
//  EJToolKit
//
//  Created by eternaljust on 2025/5/11.
//

import os
import Foundation

/// 日志配置
public struct EJLoggerConfig {
    /// 标识日志的来源（通常是应用的 Bundle Identifier）
    public static var subsystem: String = Bundle.main.bundleIdentifier ?? "EJLogger"
}

/// 日志工具
///
/// 日志等级说明：
/// Xcode 控制台：[DEBUG] 无背景、[INFO] 无背景、[NOTICE] 无背景、[ERROR] 黄底、[FAULT] 红底
/// DEBUG：trace 代码执行路径跟踪、详细调试信息（如循环次数、临时变量值），debug 开发阶段详细日志，记录中间状态或临时数据（如 API 响应原始数据）
/// INFO：记录关键状态变更（如用户登录成功、配置加载完成）
/// NOTICE：等同于 default，log 默认级别日志（可在控制台 App 中显示保留），notice 常规事件记录（如生命周期事件、耗时操作完成、视图加载完成、按钮点击）
/// ERROR：warning、error 可恢复的错误（如网络失败、数据格式错误、数据解析失败），可在控制台 App 中显示保留
/// FAULT：critical  严重但可捕获的错误（如核心组件初始化失败），fault 不可恢复的致命错误（如断言失败、关键资源丢失、容器未初始化），可在控制台 App 中显示保留
///
/// 使用场景：
/// debug：推荐记录开发阶段详细跟踪代码，示例：logger.debug("请求 URL: \(url)")、logger.debug("开始加载 loadData 方法")
/// info：推荐记录关键状态变更，示例：logger.info("用户登录成功: \(username)")、logger.info("配置文件加载完成，版本: \(config.version)")
/// notice：推荐记录常规事件，示例：logger.notice("按钮点击")、logger.notice("视图加载完成")
/// error：推荐记录可恢复错误，示例：logger.error("请求失败: \(error.localizedDescription)")、logger.error("数据解析失败: \(String(data: data, encoding: .utf8) ?? "")")
/// fault：推荐记录致命错误，示例：logger.fault("数据库校验失败")、logger.fault("SDK 未初始化")
///
/// 隐私级别：
/// public：日志内容在 Release 版本中可见，适合记录非敏感信息（如事件名称、状态变更）。
/// private: 日志内容在 Release 版本中被隐藏，显示为 <private>，适合记录敏感信息（如用户 ID）。
/// sensitive：日志内容在 Release 版本中被完全隐藏，适合记录高度敏感信息（如密码、Token）。
///
/// Examples:
///     let networkLogger = EJLogger(category: "Network")
///     let uiLogger = EJLogger(category: "UI")
///     let uid = "123456"
///     let token = "sjfsodfjslafsal"
///     networkLogger.logger.debug("\(EJLogger.extra()) 用户开始登录")
///     networkLogger.logger.info("用户登录请求完成")
///     networkLogger.logger.info("用户登录成功, token = \(token, privacy: .sensitive)")
///     uiLogger.logger.notice("用户登录操作完成")
///     uiLogger.logger.error("用户登录失败, uid = \(uid, privacy: .private)")
///     EJLogger.default.logger.fault("用户信息加载失败")
open class EJLogger {
    /// 类别
    private let category: String
    /// 需要在 Xcode console 中查看 log 时，将光标悬停在某个 log 上显示日志的输出来源。点击这个按钮，则会在编辑器中打开对应位置。
    /// OSLogMessage 字符串插值 ("用户登录成功, uid = \(uid, privacy: .private)") 这种上下文中只能在 Logger 中支持
    public let logger: Logger

    /// 默认日志类别
    public static var `default`: EJLogger = EJLogger(category: "Default")

    /// 初始化类别，推荐按基础操作、功能模块、日志用途筛选：Network、DataStorage，UI：Picture、Video、Animation，SDK：Pay、Login、Analysis、AD
    public init(category: String) {
        self.category = category
        self.logger = Logger(
            subsystem: EJLoggerConfig.subsystem,
            category: category
        )
    }

    /// 额外的文件、函数、行数信息
    public static func extra(file: String = #file, function: String = #function, line: Int = #line) -> String {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        return "[\(fileName):\(line)] \(function) - "
    }
}
