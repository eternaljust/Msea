# Msea 侧载分发说明

开发者付费账号过期后，Msea 通过「未签名 IPA + 用户自行 Apple ID 重签」的方式继续分发给老用户。本文记录打包前提、用户侧操作步骤、报错排查，以及从工程维护中沉淀下来的约定。

适用对象：能自己连电脑动手的少数用户。免费 Apple ID 签名只有 7 天有效期，用户数量继续增长时应改为续期付费账号走 TestFlight 或 `itms-services` OTA，不要在这条路上加功能。

---

## 一、分发包的两个硬性前提

包必须同时满足下面两条，否则第三方签名工具的产物装不上。

### 1. 不含任何 app extension

`TopicWidgetExtension` 和 `WidgetIntentHandler` 已于 2026-10-15 移除。

爱思助手给 `.appex` 签名时会套上主 App 的 entitlements 模板，且不给扩展独立描述文件，导致扩展的 `application-identifier` 与它自己 `Info.plist` 里的 bundle id 不匹配，iOS 判定整个包无效。

> **校正**：早期记录把根因写成「App Group entitlement 第三方证书无法满足」。实测不成立——爱思重签时会直接丢掉 App Group，`com.apple.security.application-groups` 根本不出现在产物里。真正的阻碍是扩展签名结构无效。

### 2. 不含嵌套动态框架

友盟以 `.xcframework` 提供，**设备切片是 `current ar archive` 静态库**，代码已链进主程序（`nm` 可见 `_OBJC_CLASS_$_UMConfigure` 定义在 `__DATA,__objc_data`，主程序 `otool -L` 无任何 `@rpath` 加载命令）。

但 Xcode 仍会往包里放两个约 33 KB 的**动态壳 framework**，运行时从不加载。它们是包内唯一的嵌套代码，爱思对它们签不拢，iOS 报：

```
0xe8008017 ApplicationVerificationFailed
Failed to verify code signature of .../Frameworks/UMDevice.framework :
A signed resource has been added, modified, or deleted.
```

`build/sideload/build-ipa.sh` 在打包前删除 `Frameworks/`，删除前用 `otool -L | grep @rpath` 做守卫：一旦工程真的引入了需要动态加载的库，脚本报错退出而不是静默删除。

---

## 二、打包

```bash
bash build/sideload/build-ipa.sh
```

脚本在源码副本（`build/sideload/Source`）中构建，因为工程的 SwiftLint 构建阶段带 `--fix`，直接构建会改动源文件。产物：`build/sideload/Msea-unsigned.ipa`。

构建参数关闭签名，产出未签名真机包，由接收方用自己的 Apple ID 重签：

```
CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=''
```

### 验收一个包是否合格

按顺序做，**不要跳步**：

1. `unzip -Z1 Msea-unsigned.ipa | grep -E "\.framework|appex"` → 应为空
2. 全包 Mach-O 数量应为 1（只有 `Payload/Msea.app/Msea`）
3. 签名后用 `ideviceinstaller install` 验收，**不要用 `xcrun devicectl device install app`**

第 3 条很重要：CoreDevice 通道比 legacy `installation_proxy` 宽松，同一个签名坏包 devicectl 能装上、`ideviceinstaller` 会拒。**devicectl 装成功不能证明签名正确。**

---

## 三、用户侧签名与安装步骤

### 准备

- Mac 或 Windows + 数据线 + 最新版爱思助手（**只从官网下载**，搜索引擎的高速下载站有改包版本）
- 一个**备用**免费 Apple ID。签名会模拟登录苹果服务器申请证书，iCloud 设备列表里会多出一条类似 `iMac 27寸 / 10.15.6` 的记录，**这是正常现象，不是被盗号**
- 手机已设锁屏密码
- iOS 16 及以上开启开发者模式：设置 → 隐私与安全性 → 拉到底 → 开发者模式（会重启，重启后需再确认一次）
- 认准要签的文件：**爱思里显示大小 2.43 MB、版本 2.0.0**

### 签名

1. 数据线连手机 → 手机上点「信任此电脑」。爱思认出设备后**设备标识（UDID）会自动填入**
2. 爱思 → **工具箱** → 搜索 `ipa` → 打开 **IPA 签名**
3. 点 **添加 Apple ID** → 填账号密码。⚠️ **账号是手机号必须加 `86` 前缀**，如 `8615XXXXXXXXX`，否则报 `-20101`
4. 点 **添加 IPA 文件** → 选中那个 2.43 MB 的包
5. **同时勾选** IPA 文件和 Apple ID → 点 **开始签名**
6. 开了双重认证的账号，手机会弹验证 → 允许 → 输入 6 位验证码

### 安装（最大的坑）

**IPA 签名工具不会自动安装。** 签名产物被写到另一个目录，和原文件路径不同。

- ✅ 点签名界面里的 **「打开已签名 IPA 位置」**，用那个目录里的文件去装
- ❌ 在「应用」列表里点自己添加进去的那条记录——那是**不带签名的原始包**，装它必然报「安装包验证失败」

网上大量「爱思签名成功但还是装不上」的帖子都是这个原因，和 Apple ID、和越狱都无关。

### 关于「信任证书」

**个人签不需要手动信任，装完直接就能打开。**

`设置 → 通用 → VPN 与设备管理 → 信任` 那套流程**只适用于企业签名证书**。爱思的 Apple ID 个人签产出的是**开发证书 + 设备绑定描述文件**（entitlements 里 `get-task-allow = true` 就是开发签名的标志），不走企业签的信任开关。

打不开时按顺序查：

- **开发者模式**没开（iOS 16+ 必须开）
- 只有当提示明确写着「不受信任的开发者」、且 App 出现在 **「企业 App」** 分组下，才需要做企业签的信任操作

> **校正**：`devicectl` 启动失败的错误串是 `invalid code signature, inadequate entitlements or its profile has not been explicitly trusted by the user`——**三选一的措辞，不能凭它断定是「没信任」**。要先排查签名结构本身。本文档记录前有过两次据此误判，实际原因都是友盟动态壳签坏。

### 验证是否真的成功

只看图标出现不算数。要确认：能打开 → 进入登录页 → **能登录成功**。

**用户必须重新登录一次**，这是预期行为：签名会把 Bundle ID 改写成 `com.eternaljust.Msea.<TeamID>`，等于装了个全新 App，旧数据不会带过来。

---

## 四、报错对照表

| 报错 | 原因 / 处置 |
|---|---|
| `安装包验证失败` / `无法验证其完整性` | ① **装成了未签名的原包**（最常见）② UDID 与签名时不一致 ③ 设备上有带云状图标的残留 App，手动删掉再装 |
| `0xe8008017 A signed resource has been added, modified, or deleted` | 包内有嵌套代码没签对。见第一节第 2 条 |
| `ec=-20101` account information was entered incorrectly | 账号写错；手机号没加 `86` |
| `ec=-22406` Apple ID or password is incorrect | 账号或密码错；同样检查 `86` |
| 签名失败错误码 44 | IPA 包架构问题，换原始未改动的包 |
| 签名失败错误码 45 | IPA 内含非法字符（如中文）。本工程包名与内部路径均为纯 ASCII，不会触发 |
| `anisetteData failed` | 公司网/校园网拦截，换家庭网络或手机热点 |
| `Init anisetteData failed` / 提示 adi 文件夹 | 先在 iTunes 里登录该 Apple ID，再重开爱思 IPA 签名工具 |
| 启动证书申请进程失败 | 杀毒软件拦截，退出杀软重启电脑 |
| 提示 Apple ID 已停用 | 去苹果官网登录，**等它弹窗提示**再改密码；主动去改会无效 |
| 点图标直接闪退、无提示 | 开发者模式未开；仍闪退则回查包内嵌套代码签名 |

---

## 五、已知限制与续签

- 个人签 **7 天**过期，到期图标变灰、点开闪退。续签就是重跑签名+安装，**覆盖安装即可保留数据**
- 签名**与设备标识绑定**，A 设备签的包装不到 B 设备。给多人用需逐个收集 UDID 分别签
- 免费 Apple ID 同时最多 3 个自签 App
- **固定用同一个 Apple ID 签**。换号 = 换 TeamID = 换 Bundle ID = 又变成全新 App，要重新信任、重新登录
- 友盟按 bundle id 注册的 appkey 会因包名改写而对不上，统计数据失真，功能不受影响

---

## 六、工程结构约定

- Home / Node / Notice / Profile / AppTab 等本地模块通过 pbxproj 的 `XCLocalSwiftPackageReference` 引入
- 小组件曾依赖独立的 `EJExtension` product dependency，已随小组件一并移除

### 编辑 project.pbxproj 的注意事项

**ID 必须以文件中的真实值为准，不要凭记忆转写。**

历史上出过两次事故：一是把 `EF70CDE6277AA1B20049D830` 误记成以 `B3` 结尾；二是 `BE580067` 是多行块却被按单行删除，导致 `objects` 字典残留孤儿行。改完务必用 `plutil -lint` 校验，并确认 `xcodebuild -list -project Msea.xcodeproj` 能正常解析出预期的 target 和 scheme。

---

## 七、如果要恢复小组件

代码可从 2026-10-15 之前的提交找回。恢复前需明确接受：**无法再用爱思这类第三方共享证书工具签名分发**，只能回到 Xcode 自签或 TestFlight。
