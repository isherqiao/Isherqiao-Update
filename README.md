# Isherqiao-Update

乔硕（isherqiao）所有软件的统一升级仓库。一个软件一个文件夹，互不干扰。

- 自定义域名：<https://update.qsis.cn/>
- GitHub Pages：<https://isherqiao.github.io/Isherqiao-Update/>
- 默认分支：`main`

## 目录

| 文件夹 | 软件 | 升级清单 |
|---|---|---|
| `enexam/` | 英文备考一体（离线 APK，`cn.qsis.enexam`） | `latest.json` |
| `galaxy-app/` | 吉利银河 / CarDeck 车机端 | `cardeck.json`（已迁入） |
| `qscms/` | QSCMS（文件版 / MySQL 版） | 待定 |

根目录 `index.html` 是统一入口页，列出各软件和下载链接。

## 客户端取清单的顺序

1. `https://update.qsis.cn/<软件>/latest.json`（GitHub Pages 自定义域名）
2. `https://cdn.jsdelivr.net/gh/isherqiao/Isherqiao-Update@main/<软件>/latest.json`
3. `https://raw.githubusercontent.com/isherqiao/Isherqiao-Update/main/<软件>/latest.json`
4. 原有 `https://u.qsis.cn:88/enexam/latest.json` 作为老入口兜底

`latest.json` 里的 `url` 保持一个主下载地址，另用 `urls` 数组给出镜像，客户端逐个尝试：

```json
{
  "versionCode": 13,
  "versionName": "1.9.3",
  "url": "https://update.qsis.cn/enexam/enexam-13.apk",
  "urls": [
    "https://cdn.jsdelivr.net/gh/isherqiao/Isherqiao-Update@main/enexam/enexam-13.apk",
    "https://raw.githubusercontent.com/isherqiao/Isherqiao-Update/main/enexam/enexam-13.apk",
    "https://isherqiao.github.io/Isherqiao-Update/enexam/enexam-13.apk",
    "https://u.qsis.cn:88/enexam/enexam-13.apk"
  ],
  "sha256": "……",
  "size": 2470000,
  "minSdk": 21,
  "notes": "更新说明"
}
```

## 发布规则

- 文件名带版本号，例如 `enexam-13.apk`；同名文件不覆盖，保证旧链接永远可下载。
- 先传安装包，再改 `latest.json`；顺序反了会让客户端点到 404。
- 必须保留 `sha256`；客户端校验不通过会丢弃安装包。
- GitHub 单文件上限 100 MB，APK/压缩包超过就改用 GitHub Releases。
- 清单文件不要用 CDN 做强校验入口，CDN 可能缓存旧版；安装包可以用 CDN 加速。

## 发布命令（英文备考一体）

```powershell
cd G:\GitHub\EngExamApk
php tools\publish_update.php "更新说明"
```

生成后把 `update\enexam-<版本>.apk` 和 `update\latest.json` 复制到本仓库 `enexam\`，上传到 `main`。

当前线上版本：

- `enexam` v1.9.5 / versionCode 15
- APK：`enexam/enexam-15.apk`，大小 2,470,962 字节
- SHA-256：`09d63560f376be363405a25f94cd4f853655b371c94f996117140734565eb6ac`
