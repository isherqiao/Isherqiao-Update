# 英文备考一体 · 离线 APK

- 包名：`cn.qsis.enexam`
- 当前版本：v1.9.8 / versionCode 18
- 国内主源清单：<https://u.qsis.cn:88/enexam/latest.json>
- 国内主源安装包：<https://u.qsis.cn:88/enexam/enexam-18.apk>
- 备用清单：<https://update.qsis.cn/enexam/latest.json>
- 备用安装包：<https://update.qsis.cn/enexam/enexam-18.apk>
- 用户协议：<https://update.qsis.cn/enexam/terms.html>
- 隐私政策：<https://update.qsis.cn/enexam/privacy.html>
- ICP备案号：京ICP备2021005632号（网站备案，不等同于 APP 备案）
- 安装包命名：`enexam-<versionCode>.apk`
- 签名：`enexam.keystore`（alias `enexam`），升级包必须同一签名，否则不能覆盖安装。
- 客户端只手动检查，不自动检查；手动查到新版后自动下载、校验 SHA-256、交系统安装器。
- 清单地址顺序：先 `u.qsis.cn:88`，再 `update.qsis.cn`，再 jsDelivr / GitHub Pages / Raw。

当前 APK：

- 大小：2,479,154 字节
- SHA-256：`6d26f4cbbd0d0083b8a2b3e56d0ca61e585297ad1787fa21411dd24586f729e3`

## 发布

在 `G:\GitHub\EngExamApk` 执行：

```powershell
& G:\xampp\php\php.exe tools\publish_update.php "更新说明"
```

然后用 `qsis-dual-update-publish` Skill 的发布器同时发两处：

```powershell
python "<SKILL_DIR>\scripts\publish.py" `
  --github-dir enexam `
  --u-dir /www/u/enexam `
  --files "G:\GitHub\EngExamApk\update\enexam-16.apk" "G:\GitHub\EngExamApk\update\latest.json" `
  --cred-file "G:\GitHub\_tmp_mysql_probe.py"
```

顺序固定：先传国内镜像并验证，再传 GitHub 并验证 `update.qsis.cn`。先传安装包，再更新 `latest.json`，否则客户端可能点到 404。
