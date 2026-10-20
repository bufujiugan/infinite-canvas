$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$goRoot = Join-Path $projectRoot ".runtime\go"
$bunExe = Join-Path $projectRoot ".runtime\bun-1.3.14\bun-windows-x64\bun.exe"
$distDir = Join-Path $projectRoot "dist"
$webDir = Join-Path $projectRoot "web"
$buildHome = Join-Path $projectRoot ".runtime\build-home"
$buildTemp = Join-Path $projectRoot ".runtime\temp"

if (-not (Test-Path -LiteralPath (Join-Path $goRoot "bin\go.exe"))) {
    throw "未找到便携 Go，请检查 $goRoot"
}
if (-not (Test-Path -LiteralPath $bunExe)) {
    throw "未找到便携 Bun，请检查 $bunExe"
}

New-Item -ItemType Directory -Force -Path $distDir, $buildHome, $buildTemp | Out-Null
$env:PATH = "$(Join-Path $goRoot 'bin');$(Split-Path -Parent $bunExe);$env:PATH"
$env:GOPROXY = "https://goproxy.cn,direct"
$env:GOSUMDB = "sum.golang.google.cn"
$env:APPDATA = $buildHome
$env:LOCALAPPDATA = $buildHome
$env:TEMP = $buildTemp
$env:TMP = $buildTemp
$env:NEXT_TELEMETRY_DISABLED = "1"

Push-Location $projectRoot
try {
    & (Join-Path $goRoot "bin\go.exe") build -o (Join-Path $distDir "infinite-canvas-api.exe") .
    if ($LASTEXITCODE -ne 0) {
        throw "Go 后端构建失败，退出码：$LASTEXITCODE"
    }

    Push-Location $webDir
    try {
        & $bunExe install --frozen-lockfile
        if ($LASTEXITCODE -ne 0) {
            throw "前端依赖安装失败，退出码：$LASTEXITCODE"
        }

        & $bunExe run build
        if ($LASTEXITCODE -ne 0) {
            throw "前端构建失败，退出码：$LASTEXITCODE"
        }

        $standaloneRoot = Join-Path $webDir ".next\standalone"
        $standaloneStatic = Join-Path $standaloneRoot ".next\static"
        $standalonePublic = Join-Path $standaloneRoot "public"
        New-Item -ItemType Directory -Force -Path $standaloneStatic, $standalonePublic | Out-Null
        Copy-Item -Path (Join-Path $webDir ".next\static\*") -Destination $standaloneStatic -Recurse -Force
        Copy-Item -Path (Join-Path $webDir "public\*") -Destination $standalonePublic -Recurse -Force
    }
    finally {
        Pop-Location
    }
}
finally {
    Pop-Location
}

Write-Host "构建完成：$distDir\infinite-canvas-api.exe"
