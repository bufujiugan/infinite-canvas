$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$apiExe = Join-Path $projectRoot "dist\infinite-canvas-api.exe"
$standaloneRoot = Join-Path $projectRoot "web\.next\standalone"
$standaloneServer = Join-Path $standaloneRoot "server.js"
$nodeExe = (Get-Command node -ErrorAction Stop).Source
$logsDir = Join-Path $projectRoot "logs"
$apiPidFile = Join-Path $projectRoot "data\api.pid"
$webPidFile = Join-Path $projectRoot "data\web.pid"

if (-not (Test-Path -LiteralPath $apiExe)) {
    throw "后端尚未构建，请先运行 .\build-local.ps1"
}
if (-not (Test-Path -LiteralPath $standaloneServer)) {
    throw "前端尚未构建，请先运行 .\build-local.ps1"
}

$occupiedPorts = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
    Where-Object { $_.LocalPort -in 3000, 18080 }
if ($occupiedPorts) {
    $summary = ($occupiedPorts | ForEach-Object { "$($_.LocalPort)(PID $($_.OwningProcess))" }) -join ", "
    throw "启动端口已被占用：$summary"
}

New-Item -ItemType Directory -Force -Path $logsDir, (Join-Path $projectRoot "data\prompts") | Out-Null

$apiProcess = Start-Process -FilePath $apiExe `
    -WorkingDirectory $projectRoot `
    -RedirectStandardOutput (Join-Path $logsDir "api.out.log") `
    -RedirectStandardError (Join-Path $logsDir "api.error.log") `
    -WindowStyle Hidden `
    -PassThru
$apiProcess.Id | Set-Content -LiteralPath $apiPidFile -Encoding ascii

$env:API_BASE_URL = "http://127.0.0.1:18080"
$env:HOSTNAME = "0.0.0.0"
$env:PORT = "3000"
$env:NODE_ENV = "production"
$webProcess = Start-Process -FilePath $nodeExe `
    -ArgumentList @("server.js") `
    -WorkingDirectory $standaloneRoot `
    -RedirectStandardOutput (Join-Path $logsDir "web.out.log") `
    -RedirectStandardError (Join-Path $logsDir "web.error.log") `
    -WindowStyle Hidden `
    -PassThru
$webProcess.Id | Set-Content -LiteralPath $webPidFile -Encoding ascii

Write-Host "无限画布已启动：http://127.0.0.1:3000"
Write-Host "API PID：$($apiProcess.Id)，Web PID：$($webProcess.Id)"
