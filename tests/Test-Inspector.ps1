# Offline tests only; no access to real user caches or native Codex.
$ErrorActionPreference = 'Stop'
$script = Join-Path (Split-Path $PSScriptRoot -Parent) 'Inspect-ModelCatalog.ps1'
$fixture = Join-Path $PSScriptRoot 'fixtures'
$r = @((& $script -CodexHome $fixture -AsJson) | ConvertFrom-Json)
if ($r.Count -ne 2) { throw 'Expected two cache summaries.' }
if ($r[0].Status -ne 'ok' -or $r[0].Models.Count -ne 0) { throw 'Desktop fixture failed.' }
if ($r[1].Models.Count -ne 2 -or $r[1].Models[0].Visibility -ne 'list') { throw 'CLI fixture failed.' }
$bad = Join-Path $fixture 'invalid'
$r = @((& $script -CodexHome $bad -AsJson) | ConvertFrom-Json)
if ($r[0].Status -ne 'missing' -or $r[1].Status -ne 'read-or-parse-error') { throw 'Invalid/missing handling failed.' }
$unknown = Join-Path $fixture 'unknown'
$r = @((& $script -CodexHome $unknown -AsJson) | ConvertFrom-Json)
if ($r[0].Status -ne 'unknown-format') { throw 'Schema handling failed.' }
Write-Output 'PASS: model extraction, empty catalog, UTF-8, missing/invalid file, unknown schema.'
