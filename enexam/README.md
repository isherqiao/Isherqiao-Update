# 英文备考一体 · 离线 APK

- 包名：`cn.qsis.enexam`
- 升级清单：`latest.json`
- 安装包命名：`enexam-<versionCode>.apk`
- 签名：`enexam.keystore`（alias `enexam`），升级包必须同一签名，否则不能覆盖安装。
- 客户端只手动检查，不自动检查；手动查到新版后自动下载、校验 SHA-256、交系统安装器。

## 发布

在 `G:\GitHub\EngExamApk` 执行：

```powershell
php tools\publish_update.php "更新说明"
Copy-Item update\enexam-*.apk G:\GitHub\Isherqiao-Update\enexam\
Copy-Item update\latest.json G:\GitHub\Isherqiao-Update\enexam\
```

先提交 APK，再提交 `latest.json`。
