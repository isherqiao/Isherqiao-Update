# 英文备考一体 · 离线 APK

- 包名：`cn.qsis.enexam`
- 当前版本：v1.9.5 / versionCode 15
- 升级清单：<https://update.qsis.cn/enexam/latest.json>
- 安装包：<https://update.qsis.cn/enexam/enexam-15.apk>
- 安装包命名：`enexam-<versionCode>.apk`
- 签名：`enexam.keystore`（alias `enexam`），升级包必须同一签名，否则不能覆盖安装。
- 客户端只手动检查，不自动检查；手动查到新版后自动下载、校验 SHA-256、交系统安装器。

当前 APK：

- 大小：2,470,962 字节
- SHA-256：`09d63560f376be363405a25f94cd4f853655b371c94f996117140734565eb6ac`

## 发布

在 `G:\GitHub\EngExamApk` 执行：

```powershell
php tools\publish_update.php "更新说明"
Copy-Item update\enexam-*.apk G:\GitHub\Isherqiao-Update\enexam\
Copy-Item update\latest.json G:\GitHub\Isherqiao-Update\enexam\
```

先上传 APK，再更新 `latest.json`，否则客户端可能点到 404。
