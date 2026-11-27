# 乔硕 App 升级站 · 正式发布脚本（GitHub API 上传）
# 由发版系统（127.0.0.1:100 的 update 项目）在「正式发布」时调用：
#   1) 对比本地仓库 HEAD 与 GitHub isherqiao/Isherqiao-Update main 的文件内容
#   2) 有差异就把变化的文件通过 GitHub API 上传，生成一次提交挂到 main（相当于把文件放进对应目录）
#   3) 把本次 tag 建到这次提交上
#   4) 校验 https://update.qsis.cn/ 返回 200
# 为什么不用 git push：本机 Apache 以 SYSTEM 运行，SSH 私钥权限校验过不去、HTTPS 又常被重置；
# GitHub API(api.github.com) 在这台机器上是稳定的，令牌从环境变量 GITHUB_TOKEN 读取。

param(
    [string]$Ref  = '',   # 版本标识（tag 名），由发版系统传入 {ref}
    [string]$Note = '',   # 提交说明，由发版系统传入 {note}
    [string]$Repo = ''    # 项目目录，由发版系统传入 {repo}
)

$ErrorActionPreference = 'Stop'

$root = if ($Repo) { $Repo } else { Split-Path -Parent $PSScriptRoot }
Set-Location -LiteralPath $root

$git = 'D:/Program Files (x86)/Git/cmd/git.exe'
if (-not (Test-Path -LiteralPath $git)) { throw "找不到 git：$git" }

$tok = $env:GITHUB_TOKEN
if (-not $tok) { throw 'GITHUB_TOKEN 未设置，请在发版系统「设置 → 脚本发布环境变量」里填 GITHUB_TOKEN=ghp_...' }

$owner = 'isherqiao'
$repoName = 'Isherqiao-Update'
$branch = 'main'
$api = "https://api.github.com/repos/$owner/$repoName"

$headers = @{
    'Authorization' = "token $tok"
    'User-Agent'    = 'qsis-ver-publisher'
    'Accept'        = 'application/vnd.github+json'
}
function Call([string]$method, [string]$url, $body = $null) {
    $json = $null
    if ($null -ne $body) { $json = ($body | ConvertTo-Json -Depth 12 -Compress) }
    $p = @{ Method = $method; Uri = $url; Headers = $headers; TimeoutSec = 60 }
    if ($json) { $p['Body'] = $json; $p['ContentType'] = 'application/json; charset=utf-8' }
    for ($i = 1; $i -le 4; $i++) {
        try { return Invoke-RestMethod @p }
        catch {
            if ($i -eq 4) { throw "GitHub API $method $url 失败：$($_.Exception.Message)" }
            Start-Sleep -Seconds 5
        }
    }
}

# 1) 远端现状
$refInfo = Call 'GET' "$api/git/ref/heads/$branch"
$headSha = $refInfo.object.sha
$headCommit = Call 'GET' "$api/git/commits/$headSha"
$baseTree = $headCommit.tree.sha

$remoteTree = Call 'GET' "$api/git/trees/$baseTree`?recursive=1"
$remoteMap = @{}
foreach ($t in $remoteTree.tree) { if ($t.type -eq 'blob') { $remoteMap[$t.path] = $t.sha } }

# 2) 本地 HEAD 文件清单（内容 sha 与 GitHub blob sha 同一套算法，可直接比）
$lsOut = & $git -C $root -c safe.directory=* ls-tree -r -z HEAD
if ($LASTEXITCODE -ne 0) { throw '读取本地 HEAD 文件清单失败，仓库可能没有提交。' }
$localMap = @{}
$localMode = @{}
foreach ($rec in ($lsOut -split "`0")) {
    if ($rec -eq '') { continue }
    $meta, $path = $rec -split "`t", 2
    $parts = $meta -split ' '
    $localMap[$path] = $parts[2]
    $localMode[$path] = $parts[0]
}

# 3) 计算差异
$changed = @()
$deleted = @()
foreach ($kv in $localMap.GetEnumerator()) {
    if (-not $remoteMap.ContainsKey($kv.Key) -or $remoteMap[$kv.Key] -ne $kv.Value) { $changed += $kv.Key }
}
foreach ($path in $remoteMap.Keys) {
    if (-not $localMap.ContainsKey($path)) { $deleted += $path }
}

"本地文件 $($localMap.Count) 个，远端 $($remoteMap.Count) 个，变化 $($changed.Count) 个，删除 $($deleted.Count) 个"

$treeEntries = @()
foreach ($path in $changed) {
    $full = Join-Path $root ($path -replace '/', '\')
    $bytes = [IO.File]::ReadAllBytes($full)
    $blob = Call 'POST' "$api/git/blobs" @{ content = [Convert]::ToBase64String($bytes); encoding = 'base64' }
    $treeEntries += @{ path = $path; mode = $localMode[$path]; type = 'blob'; sha = $blob.sha }
    "  + $path"
}
foreach ($path in $deleted) {
    $treeEntries += @{ path = $path; mode = '100644'; type = 'blob'; sha = $null }
    "  - $path"
}

if ($treeEntries.Count -gt 0) {
    $newTree = Call 'POST' "$api/git/trees" @{ base_tree = $baseTree; tree = $treeEntries }
    $msg = if ($Note -ne '') { $Note } else { "publish $Ref" }
    $newCommit = Call 'POST' "$api/git/commits" @{ message = $msg; tree = $newTree.sha; parents = @($headSha) }
    $upd = Call 'PATCH' "$api/git/refs/heads/$branch" @{ sha = $newCommit.sha; force = $false }
    $headSha = $newCommit.sha
    "已提交到 GitHub main：$($headSha.Substring(0,7))（$msg）"
} else {
    "内容与 GitHub main 一致，不产生新提交"
}

# 4) tag 指到这次提交
if ($Ref -ne '') {
    $tagUrl = "$api/git/refs/tags/" + [uri]::EscapeDataString($Ref)
    try {
        $old = Call 'GET' $tagUrl
        Call 'PATCH' $tagUrl @{ sha = $headSha; force = $true } | Out-Null
        "已更新 tag：$Ref"
    } catch {
        Call 'POST' "$api/git/refs" @{ ref = "refs/tags/$Ref"; sha = $headSha } | Out-Null
        "已创建 tag：$Ref"
    }
}

# 5) 校验线上首页
$ok = $false
for ($i = 1; $i -le 12; $i++) {
    try {
        $r = Invoke-WebRequest -Uri 'https://update.qsis.cn/' -UseBasicParsing -TimeoutSec 20
        if ($r.StatusCode -eq 200) {
            "线上首页 200，长度 $($r.RawContentLength) 字节"
            $ok = $true
            break
        }
    } catch {
        if ($i -eq 12) { throw "校验 https://update.qsis.cn/ 失败：$($_.Exception.Message)" }
        Start-Sleep -Seconds 10
    }
}
if (-not $ok) { throw '线上首页不是 200' }

Write-Output '正式发布完成。'
