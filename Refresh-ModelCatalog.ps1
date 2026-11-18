# Optional diagnostic. May contact the service and update its catalog cache.
# Does not install software, modify config, delete cache, restart apps, or run inference.
[CmdletBinding()]
param([switch]$RunRefresh)
$ErrorActionPreference = 'Stop'
if (-not $RunRefresh) {
    Write-Output '尚未执行。此脚本会联网请求模型目录，并可能更新缓存。'
    Write-Output '阅读使用说明后，显式加 -RunRefresh 才会执行。'
    return
}
if (-not (Get-Command Get-AppxPackage -ErrorAction SilentlyContinue)) {
    throw '找不到 Windows 应用包查询命令；停止，不安装其他程序。'
}
$packages = @(Get-AppxPackage -Name OpenAI.Codex)
if ($packages.Count -ne 1) {
    throw '没有找到唯一的 OpenAI.Codex 安装包；停止，不猜测安装路径。'
}
$exe = Join-Path $packages[0].InstallLocation 'app\resources\codex.exe'
if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) {
    throw '本版本内置程序位置不同；停止，不尝试其他可执行文件。'
}
Write-Output '将运行当前 Windows 应用包自带的模型目录诊断。'
Write-Output '请等待返回；如长时间无响应，按 Ctrl+C 结束本次诊断，不要重复开窗口。'
& $exe debug models 2>$null | Out-Null
$code = $LASTEXITCODE
Write-Output "诊断退出码：$code"
if ($code -eq 0) {
    Write-Output '诊断已结束。请重新执行 Inspect-ModelCatalog.ps1，并检查新建 Work 的模型菜单。'
} else {
    Write-Output '诊断未成功；请停止，不连续重试。退出码用于反馈，不代表菜单已修复。'
}
