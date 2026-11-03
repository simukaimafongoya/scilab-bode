$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
$distRoot = Join-Path $projectRoot 'dist'
$versionLine = Get-Content (Join-Path $projectRoot 'DESCRIPTION') | Where-Object { $_ -match '^Version: ' }
$version = ($versionLine -replace '^Version: ', '').Trim()
# A fresh staging folder prevents removed files from leaking into later releases.
$stageRoot = Join-Path $distRoot ('stage-' + [guid]::NewGuid().ToString('N'))
$packageRoot = Join-Path $stageRoot 'tfbode'
foreach ($required in @('macros/lib', 'loader.sce', 'unloader.sce')) {
    if (-not (Test-Path -LiteralPath (Join-Path $projectRoot $required))) {
        throw 'Run builder.sce in Scilab before packaging.'
    }
}
New-Item -ItemType Directory -Force -Path $packageRoot | Out-Null
foreach ($item in @('macros', 'etc', 'demos', 'DESCRIPTION', 'LICENSE', 'COPYING-BSD', 'README.md', 'REVIEW.md', 'install.sce', 'builder.sce', 'loader.sce', 'unloader.sce', 'cleaner.sce')) {
    Copy-Item -LiteralPath (Join-Path $projectRoot $item) -Destination $packageRoot -Recurse -Force
}
$archivePath = Join-Path $distRoot ('tfbode-' + $version + '-scilab-2026.1.zip')
Compress-Archive -LiteralPath $packageRoot -DestinationPath $archivePath -Force
Write-Output $archivePath
