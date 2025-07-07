@echo off
chcp 65001 >nul
setlocal

REM 配置参数
set "USERNAME=校园网账号"
set "PASSWORD=校园网密码"
set "USERIP=xxx.xxx.xxx.xxx"

set "CHECK_HOST=www.baidu.com"

set "LOGIN_URL=http://172.16.253.3:801/eportal/?c=Portal&a=login&callback=dr1003&login_method=1&user_account=%USERNAME%&user_password=%PASSWORD%&wlan_user_ip=%USERIP%" 
REM&wlan_user_ipv6=&wlan_user_mac=000000000000&wlan_ac_ip=172.16.253.1&wlan_ac_name=&jsVersion=3.3.2&v=3363"

:loop
REM 检查网络连接（ping 1次，等待1秒）
ping -n 1 -w 1000 %CHECK_HOST% >nul
if errorlevel 1 (
    echo 网络断开，尝试发送登录请求...
    
    REM 使用 curl 发送 GET 请求（确保系统已安装 curl，Win10+ 默认支持）
    curl -s "%LOGIN_URL%" >nul

    echo 登录请求已发送。
) else (
    echo 网络正常，3秒后自动关闭窗口...
    timeout /t 3 >nul
    exit
)

REM 等待 10 秒再检查一次（你可改为更长，如 3 小时即 timeout /t 10800）
timeout /t 10 >nul
goto loop
