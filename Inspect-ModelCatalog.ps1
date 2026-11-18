# Default: local read-only inspection. No network, configuration writes, or process restarts.
[CmdletBinding()]
param(
    [string]$CodexHome,
    [string]$ModelPrefix = 'gpt-6.2',
    [switch]$AsJson
)
$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($CodexHome)) {
    if (-not [string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
        $CodexHome = $env:CODEX_HOME
    } else {
        $CodexHome = Join-Path $HOME '.codex'
    }
}
$names = @('models_cache.codex_work_desktop.json', 'models_cache.json')
$results = @(foreach ($name in $names) {
    $result = [ordered]@{
        File = $name; Status = 'missing'; FetchedAt = $null
        ClientVersion = $null; Models = @()
    }
    $path = Join-Path $CodexHome $name
    try {
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            if ((Get-Item -LiteralPath $path).Length -gt 20MB) {
                $result.Status = 'too-large'
            } else {
                $data = Get-Content -LiteralPath $path -Raw -Encoding UTF8 |
                    ConvertFrom-Json -ErrorAction Stop
                if ($null -eq $data -or $null -eq $data.PSObject.Properties['models'] -or
                    $null -eq $data.models -or $data.models -isnot [System.Array]) {
                    $result.Status = 'unknown-format'
                } else {
                    $result.Status = 'ok'
                    $result.FetchedAt = $data.fetched_at
                    $result.ClientVersion = $data.client_version
                    $result.Models = @($data.models | Where-Object {
                        $_.slug -is [string] -and
                        $_.slug.StartsWith($ModelPrefix, [StringComparison]::OrdinalIgnoreCase)
                    } | ForEach-Object {
                        [pscustomobject]@{Slug = $_.slug; Visibility = $_.visibility}
                    })
                }
            }
        }
    } catch {
        # Do not print raw JSON, paths, stack traces, or exception contents.
        $result.Status = 'read-or-parse-error'
    }
    [pscustomobject]$result
})
if ($AsJson) {
    ConvertTo-Json -InputObject $results -Depth 6
} else {
    foreach ($r in $results) {
        Write-Output "`n文件：$($r.File)"
        Write-Output "读取状态：$($r.Status)"
        if ($r.Status -eq 'ok') {
            Write-Output "抓取时间：$($r.FetchedAt)"
            Write-Output "目录记录版本：$($r.ClientVersion)"
            if ($r.Models.Count -eq 0) {
                Write-Output "没有匹配 $ModelPrefix 的模型条目。"
            } else {
                $r.Models | Format-Table -AutoSize
            }
        }
    }
    Write-Output "`n完成。没有修改文件或联网。完整状态解释见 使用说明.txt。"
}
