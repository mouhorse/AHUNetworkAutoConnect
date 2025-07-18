@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ========== 用户配置 ==========
set "USERNAME=校园网账号"
set "PASSWORD=校园网密码"
:: ==========================



:: ========== 自我介绍 ==========
echo.
echo ===============================================
echo.
echo        校园网自动登录脚本  v1.1
echo.
echo   作者：mouhorse
echo   功能：自动获取 IP 并登录校园网
echo   提示：如需修改账号，请编辑脚本里的 USERNAME 和 PASSWORD
echo.
echo ===============================================
echo.
echo 正在启动，请稍候 3 秒...
echo.
timeout /t 3 >nul
:: ===========================================



set "CHECK_HOST=www.baidu.com"
set "LOGIN_BASE=http://172.16.253.3:801/eportal/?c=Portal&a=login&callback=dr1003&login_method=1"

:loop
set "USERIP="
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /c:"IPv4 Address" ^| findstr /v /c:"169.254"') do (
    for /f "tokens=1 delims= " %%a in ("%%i") do ( 
        set "USERIP=%%a"  
        goto :done
    )
)
:done

if "!USERIP!"=="" (
    echo [%date% %time%] 获取 IP 失败，10 秒后重试...
    timeout /t 10 >nul
    goto loop
)

set "LOGIN_URL=!LOGIN_BASE!&user_account=!USERNAME!&user_password=!PASSWORD!&wlan_user_ip=!USERIP!"

ping -n 1 -w 1000 %CHECK_HOST% >nul
if errorlevel 1 (
    echo [%date% %time%] 网络断开，尝试登录（IP=!USERIP!）...
    curl -s "!LOGIN_URL!" >nul
    timeout /t 10 >nul
    goto loop
) else (
    echo [%date% %time%] 网络正常，5 秒后关闭窗口...
    timeout /t 5 >nul
    exit
)