@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ========== 用户配置 ==========
set "USERNAME=账号"
set "PASSWORD=密码"
set "CHECK_HOST="
set "LOGIN_BASE=http://172.16.253.3:801/eportal/?c=Portal&a=login&callback=dr1003&login_method=1"
:: ==============================

set COUNT=0  :: 初始化登录尝试计数器

:loop
:: 1. 重新获取 IPv4
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

:: 2. 根据IP动态设置CHECK_HOST
for /f "tokens=1-4 delims=." %%a in ("!USERIP!") do (
    set "CHECK_HOST=%%a.%%b.0.1"
)

:: 3. 拼登录 URL
set "LOGIN_URL=!LOGIN_BASE!&user_account=!USERNAME!&user_password=!PASSWORD!&wlan_user_ip=!USERIP!"

:: 4. 检测网络
ping -n 1 -w 1000 !CHECK_HOST! >nul
if errorlevel 1 (
    set /a COUNT+=1
    if !COUNT! gtr 10 (
        echo [%date% %time%] 已尝试登录10次均失败，准备重启电脑...
        timeout /t 5 >nul
        shutdown /r /t 0
        exit
    )
    echo [%date% %time%] 网络断开，尝试登录（IP=!USERIP!，网关=!CHECK_HOST!） 第!COUNT!次...
    curl -s "!LOGIN_URL!" >nul
    timeout /t 10 >nul
    goto loop
) else (
    echo [%date% %time%] 网络正常（网关=!CHECK_HOST!），5 秒后关闭窗口...
    timeout /t 5 >nul
    exit
)