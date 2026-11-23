# Isherqiao-Update

乔硕（isherqiao）所有软件的统一升级仓库。一个软件一个文件夹，互不干扰。

- 国内主源：<https://u.qsis.cn:88/>
- 自定义域名：<https://update.qsis.cn/>
- GitHub Pages：<https://isherqiao.github.io/Isherqiao-Update/>
- 默认分支：`main`

## 双通道规则

每个新版本必须同时发两处，顺序固定：

1. 先上传国内镜像 `https://u.qsis.cn:88/<软件>/`，并验证 200、大小、SHA-256。
2. 再上传本仓库 `<软件>/`，等 GitHub Pages 构建完成后验证 `https://update.qsis.cn/<软件>/`。

国内镜像速度快、不消耗 GitHub 流量；本仓库作为异地兜底。只发一处不算发布完成。

## 目录

| 文件夹 | 软件 | 升级清单 | 国内镜像 |
|---|---|---|---|
| `enexam/` | 英文备考一体（离线 APK，`cn.qsis.enexam`） | `latest.json` | `/www/u/enexam/` |
| `DCITA/` | 词根词典 A端（WebView APK，`cn.qsis.tools`） | `latest.json` | `/www/u/DCITA/` |
| `galaxy-app/` | 吉利银河 / CarDeck 车机端 | `cardeck.json` | `/www/u/`（已迁入） |
| `qscms/` | QSCMS（文件版 / MySQL 版） | 待定 | 待定 |

根目录 `index.html` 是统一入口页，列出各软件和下载链接。

## 客户端取清单的顺序

1. `https://u.qsis.cn:88/<软件>/latest.json`（国内镜像，首选）
2. `https://update.qsis.cn/<软件>/latest.json`（GitHub Pages 自定义域名）
3. `https://cdn.jsdelivr.net/gh/isherqiao/Isherqiao-Update@main/<软件>/latest.json`
4. `https://isherqiao.github.io/Isherqiao-Update/<软件>/latest.json`
5. `https://raw.githubusercontent.com/isherqiao/Isherqiao-Update/main/<软件>/latest.json`

`latest.json` 里的 `url` 是首选地址，另用 `urls` 数组给出完整镜像，客户端逐个尝试：

```json
{
  "versionCode": 16,
  "versionName": "1.9.6",
  "url": "https://u.qsis.cn:88/enexam/enexam-16.apk",
  "urls": [
    "https://u.qsis.cn:88/enexam/enexam-16.apk",
    "https://update.qsis.cn/enexam/enexam-16.apk",
    "https://cdn.jsdelivr.net/gh/isherqiao/Isherqiao-Update@main/enexam/enexam-16.apk",
    "https://isherqiao.github.io/Isherqiao-Update/enexam/enexam-16.apk",
    "https://raw.githubusercontent.com/isherqiao/Isherqiao-Update/main/enexam/enexam-16.apk"
  ],
  "sha256": "……",
  "size": 2470962,
  "minSdk": 21,
  "notes": "更新说明"
}
```

## 发布命令（词根词典 A 端）

```powershell
cd G:\GitHub\ToolsApk
.\release.ps1 "更新说明"
```

发布目录固定为 GitHub `DCITA/` 和国内镜像 `/www/u/DCITA/`。A 端 APP 是独立 WebView 壳项目，不在 `RootDictDist/a-client` 的 git 历史里；详细说明见 [`DCITA/README.md`](DCITA/README.md)。

当前线上版本：

- `DCITA` v1.3 / versionCode 4
- APK：`https://u.qsis.cn:88/DCITA/dcita-4.apk`
- 备用：`https://update.qsis.cn/DCITA/dcita-4.apk`
- 大小 12,685 字节
- SHA-256：`bd2edf64750a7286baed259d784357a382a254ddfd5e971521da022fb83052c3`

## 发布规则

- 文件名带版本号，例如 `enexam-16.apk`；同名文件不覆盖，保证旧链接永远可下载。
- 先传安装包，再改 `latest.json`；顺序反了会让客户端点到 404。
- 必须保留 `sha256`；客户端校验不通过会丢弃安装包。
- GitHub 单文件上限 100 MB，APK/压缩包超过就改用 GitHub Releases。
- `latest.json` 不要强依赖 CDN；CDN 可能缓存旧清单，安装包可以用 CDN 加速。
- SFTP 通道：`s.qsis.cn:222`，用户 `root`，站点目录 `/www/u/`；88 只收 HTTPS。
- 服务器 nginx 配置：`/etc/nginx/conf.d/u.qsis.cn.conf`，只监听 88。

## 发布命令（英文备考一体）

```powershell
cd G:\GitHub\EngExamApk
& G:\xampp\php\php.exe tools\publish_update.php "更新说明"
```

然后用 `qsis-dual-update-publish` Skill 的发布器一次同步两处：

```powershell
python "<SKILL_DIR>\scripts\publish.py" `
  --github-dir enexam `
  --u-dir /www/u/enexam `
  --files "G:\GitHub\EngExamApk\update\enexam-16.apk" "G:\GitHub\EngExamApk\update\latest.json" `
  --cred-file "G:\GitHub\_tmp_mysql_probe.py"
```

当前线上版本：

- `enexam` v1.9.8 / versionCode 18
- 国内主源：`https://u.qsis.cn:88/enexam/enexam-18.apk`
- 备用：`https://update.qsis.cn/enexam/enexam-18.apk`
- 大小 2,479,154 字节
- SHA-256：`6d26f4cbbd0d0083b8a2b3e56d0ca61e585297ad1787fa21411dd24586f729e3`
- 用户协议：<https://update.qsis.cn/enexam/terms.html>
- 隐私政策：<https://update.qsis.cn/enexam/privacy.html>
