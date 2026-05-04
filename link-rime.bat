@echo off
setlocal enabledelayedexpansion

set "dest=%APPDATA%\Rime"
if not exist "%dest%" (
    echo 目標資料夾不存在: %dest%
    exit /b 1
)

REM 檢查是否同一磁碟機（簡易判斷）
set "cur_drive=%~d0"
set "dest_drive=%dest:~0,2%"
if /i not "%cur_drive%"=="%dest_drive%" (
    echo 當前目錄 (%cur_drive%) 與 Rime 目錄 (%dest_drive%) 不在同一磁碟區，無法建立硬連結。
    exit /b 1
)

set "found=0"
for %%F in (*.schema.yaml dict.yaml) do (
    if exist "%%F" (
        set "found=1"
        set "target=%dest%\%%F"
        if exist "!target!" (
            echo 目標已存在: !target!
            set /p "overwrite=是否覆蓋？(y/n): "
            if /i not "!overwrite!"=="y" (
                echo 跳過 %%F
                continue
            )
            del "!target!" >nul 2>&1
        )
        mklink /H "!target!" "%%F" >nul 2>&1
        if errorlevel 1 (
            echo 建立失敗: %%F （可能權限不足或跨磁碟區）
        ) else (
            echo 已建立硬連結: %%F -^> !target!
        )
    )
)

if "%found%"=="0" (
    echo 沒有找到任何 *.schema.yaml 或 dict.yaml 檔案。
)

echo 完成！
pause