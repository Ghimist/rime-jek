# link-rime.ps1
$ErrorActionPreference = "Stop"

$destDir = "$env:APPDATA\Rime"
if (-not (Test-Path $destDir)) {
    Write-Error "目標資料夾不存在: $destDir"
    exit 1
}

# 檢查是否為同一磁碟區
$currentDrive = (Get-Location).Drive.Root
$destDrive = (Get-Item $destDir).PSDrive.Root
if ($currentDrive -ne $destDrive) {
    Write-Warning "當前目錄 ($currentDrive) 與 Rime 目錄 ($destDrive) 不在同一磁碟區，硬連結將無法建立。"
    exit 1
}

$files = Get-ChildItem -Path . -Include @("*.schema.yaml", "dict.yaml") -File

if ($files.Count -eq 0) {
    Write-Host "沒有找到任何 *.schema.yaml 或 dict.yaml 檔案。" -ForegroundColor Yellow
    exit 0
}

foreach ($file in $files) {
    $destFile = Join-Path $destDir $file.Name

    if (Test-Path $destFile) {
        Write-Host "目標已存在: $destFile" -ForegroundColor Yellow
        $response = Read-Host "是否覆蓋？(y/n)"
        if ($response -ne 'y') {
            Write-Host "跳過 $($file.Name)" -ForegroundColor Cyan
            continue
        }
        Remove-Item $destFile -Force
    }

    New-Item -ItemType HardLink -Path $destFile -Value $file.FullName | Out-Null
    Write-Host "已建立硬連結: $($file.Name) -> $destFile" -ForegroundColor Green
}

Write-Host "完成！" -ForegroundColor Green