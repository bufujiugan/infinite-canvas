$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$apiPidFile = Join-Path $projectRoot "data\api.pid"
$webPidFile = Join-Path $projectRoot "data\web.pid"

if (Test-Path -LiteralPath $webPidFile) {
    $webProcessId = [int](Get-Content -LiteralPath $webPidFile -Raw)
    $webProcess = Get-Process -Id $webProcessId -ErrorAction SilentlyContinue
    if ($webProcess) {
        Stop-Process -Id $webProcessId
        Wait-Process -Id $webProcessId -ErrorAction SilentlyContinue
    }
    Remove-Item -LiteralPath $webPidFile
}

if (Test-Path -LiteralPath $apiPidFile) {
    $apiProcessId = [int](Get-Content -LiteralPath $apiPidFile -Raw)
    $apiProcess = Get-Process -Id $apiProcessId -ErrorAction SilentlyContinue
    if ($apiProcess) {
        Stop-Process -Id $apiProcessId
        Wait-Process -Id $apiProcessId -ErrorAction SilentlyContinue
    }
    Remove-Item -LiteralPath $apiPidFile
}

Write-Host "无限画布本机进程已停止。"
