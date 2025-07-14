@echo off

:: ==================================================================
:: ส่วนที่ 1: ตรวจสอบและขอสิทธิ์ Administrator
:: ==================================================================
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"="
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
:gotAdmin
    cd /d "%~dp0"
    chcp 65001 > nul
    title Super Uninstaller - ล้างโปรแกรมทุกเวอร์ชัน

:: ==================================================================
:: ส่วนที่ 2: เริ่มกระบวนการ
:: ==================================================================
cls
echo =======================================================
echo          สคริปต์ล้างโปรแกรมทุกเวอร์ชัน
echo =======================================================
echo.
echo      สคริปต์นี้จะค้นหาและถอนการติดตั้งโปรแกรมทุกเวอร์ชัน
echo      ที่เคยสร้างมาทั้งหมด (bye-bye..., AppBlocker, StudentFocusGuard)
echo.
echo =======================================================
echo.
echo      กด Enter เพื่อเริ่มทำการล้างระบบ...
pause
cls

echo กำลังเริ่มกระบวนการล้างข้อมูล... กรุณารอสักครู่...
echo.

:: --- [ข้อมูลทั้งหมด] รายชื่อโปรเซสและโฟลเดอร์ของทุกเวอร์ชัน ---
set "ALL_PROCESSES=bye-bye Roblox.exe" "bye-bye Gamer.exe" "AppBlocker.exe" "SystemCoreService.exe" "StudentFocusGuard.exe"
set "ALL_FOLDERS_PF=ByeByeRoblox" "ByeByeGamer" "AppBlocker" "SystemCoreService" "StudentFocusGuard"
set "ALL_FOLDERS_DOCS=ByeByeRobloxApp" "ByeByeGamerApp" "StudentFocusGuardApp"
set "ALL_STARTUP_LNK="Bye-Bye Gamer.lnk" "Bye-Bye Roblox.lnk" "StudentFocusGuard.lnk""

:: --- 1. ปิดโปรเซสเก่าทั้งหมด ---
echo [1/5] กำลังสั่งปิดโปรเซสทั้งหมดที่เกี่ยวข้อง...
for %%P in (%ALL_PROCESSES%) do (
    wmic process where "name like '%%P'" delete > nul 2>&1
)
echo    - ตรวจสอบและปิดโปรเซสเรียบร้อยแล้ว
timeout /t 2 /nobreak > nul
echo.

:: --- 2. ลบ Shortcut ออกจาก Startup ---
echo [2/5] กำลังลบ Shortcut ทั้งหมดออกจาก Startup...
for %%S in (%ALL_STARTUP_LNK%) do (
    if exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\%%~S" (
        del "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\%%~S" /f /q
        echo    - ลบ Shortcut '%%~S' แล้ว
    )
)
if exist "%commonstartup%\StudentFocusGuard_Healer.bat" (
    del "%commonstartup%\StudentFocusGuard_Healer.bat" /f /q
    echo    - ลบไฟล์ Healer.bat แล้ว
)
echo    - ตรวจสอบ Shortcut เรียบร้อยแล้ว
timeout /t 2 /nobreak > nul
echo.

:: --- 3. รันตัวถอนการติดตั้งของ Inno Setup (ถ้ามี) ---
echo [3/5] กำลังรันตัวถอนการติดตั้งของเวอร์ชันเก่าแบบเงียบ...
for %%F in (%ALL_FOLDERS_PF%) do (
    if exist "%ProgramFiles(x86)%\%%~F\unins000.exe" (
        echo    - พบตัวถอนการติดตั้งของ "%%~F", กำลังรัน...
        start /wait "" "%ProgramFiles(x86)%\%%~F\unins000.exe" /SILENT /SUPPRESSMSGBOXES
    )
)
echo    - ตรวจสอบตัวถอนการติดตั้งเรียบร้อยแล้ว
timeout /t 2 /nobreak > nul
echo.

:: --- 4. ลบโฟลเดอร์ที่ติดตั้งแบบ Portable ---
echo [4/5] กำลังลบโฟลเดอร์ที่ติดตั้งแบบ Portable ใน Documents...
for %%D in (%ALL_FOLDERS_DOCS%) do (
    if exist "%USERPROFILE%\Documents\%%~D" (
        echo    - พบโฟลเดอร์ "%%~D", กำลังลบ...
        rd /s /q "%USERPROFILE%\Documents\%%~D"
    )
)
echo    - ตรวจสอบโฟลเดอร์ Portable เรียบร้อยแล้ว
timeout /t 2 /nobreak > nul
echo.

:: --- 5. ทำความสะอาดไฟล์ hosts ---
echo [5/5] กำลังทำความสะอาดไฟล์ hosts...
set "HOSTS_PATH=%windir%\System32\drivers\etc\hosts"
set "TEMP_HOSTS=%TEMP%\hosts.temp"
findstr /v /c:"# Blocked by" "%HOSTS_PATH%" > "%TEMP_HOSTS%"
if exist "%TEMP_HOSTS%" (
    copy /y "%TEMP_HOSTS%" "%HOSTS_PATH%" > nul
    del "%TEMP_HOSTS%"
    echo    - ทำความสะอาดไฟล์ hosts เรียบร้อยแล้ว
) else (
    echo    - ไม่พบการบล็อกในไฟล์ hosts
)
timeout /t 2 /nobreak > nul
echo.

:: --- จบกระบวนการ ---
echo =======================================================
echo.
echo      กระบวนการล้างข้อมูลทุกเวอร์ชันเสร็จสิ้น!
echo      ขอแนะนำให้รีสตาร์ทเครื่องหนึ่งครั้งเพื่อความสะอาดสูงสุด
echo.
echo =======================================================
pause
exit