# 词根词典 A端（DCITA）

A 端 Android WebView 壳，包名 `cn.qsis.tools`，应用名“词根词典”。

- 当前版本：v1.2 / versionCode 3
- APK：`dcita-3.apk`，12,685 字节
- SHA-256：`0cee472eb4034947526d113e904718e29993e8c283752e75040d66031eb780fd`
- 国内主源：<https://u.qsis.cn:88/DCITA/dcita-3.apk>
- 备用：<https://update.qsis.cn/DCITA/dcita-3.apk>
- 升级清单：<https://u.qsis.cn:88/DCITA/latest.json>

## 它是什么

- 源码不在 `G:\GitHub\RootDictDist\a-client`。A 端 PHP Web 的主干、分支、历史里都没有 Android 工程或 APK。
- 真正的 A 端 APP 是独立项目 `G:\GitHub\ToolsApk`。
- APP 只负责 WebView 壳，启动加载 `http://tools.qsis.cn/`；页面、词库、考试逻辑仍在 A 端 Web 程序里。
- 纯 A 端口径：不含词根数据库、不含 TTS；这些在 B 端。

## 改哪里

- 改页面、样式、词库、考试逻辑：改 `G:\GitHub\RootDictDist\a-client\` 的 PHP/前端文件，部署 Web 即可，手机打开 APP 会自动看到新页面，不需要重新发 APK。
- 改 APP 图标、名称、启动地址、权限、WebView 行为：改 `G:\GitHub\ToolsApk\`，然后重新打 APK。
- 版本号：`G:\GitHub\ToolsApk\app\AndroidManifest.xml` 的 `versionCode` / `versionName`。

## 一键发布

```powershell
cd G:\GitHub\ToolsApk
.\release.ps1 "本次更新说明"
```

脚本会：

1. 调 `build.ps1` 构建 `ToolsWebView.apk`；
2. 复制为 `update\dcita-<versionCode>.apk`；
3. 生成 `update\latest.json`，国内地址排第一；
4. 先上传 `u.qsis.cn:88/DCITA/` 并校验；
5. 再上传 GitHub `Isherqiao-Update/DCITA/`，等 Pages 构建后校验 `update.qsis.cn/DCITA/`。

只重发当前包：`.\release.ps1 "说明" -SkipBuild`。只生成清单：`.\release.ps1 "说明" -SkipBuild -NoPublish`。

## 注意

- 当前壳没有内嵌自动升级代码，`latest.json` 已准备好，但旧版 APP 不会自己下载安装；后续给 `MainActivity.java` 加更新检查后才会自动升级。
- 网站 ICP 备案号不能代替 APP 备案号；本 APP 目前只有网站备案，没有 APP 备案。
- A 端 APP 的启动地址目前仍是 HTTP `http://tools.qsis.cn/`；上架前建议确认 HTTPS 可用后改为 HTTPS。
