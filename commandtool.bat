@echo OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
TITLE Quick Command Tool - Target: No Target Selected
COLOR B
CLS
@pushd %~dp0

SET PsExecPath=
REM PsExecPath is only needed if you intend on using PsExec, otherwise this can be left alone.

SET NeedAdmin=1
REM Only set NeedAdmin to 0 if you will never need admin permissions for this tool. Conversely, setting to 1 will always auto-elevate it.

SET Logging=
REM Experimental feature to automatically write ticket notes. Enter anything here to enable it, or leave blank to disable it.

SET p1=0
SET d1=0
REM These will set network locations. p# for print servers and d# for shared drives. Will automatically open when selected. Can be scaled as needed.

SET User=
REM Set a persistent admin username here if you want to skip through the startup.

SET Pass=
REM Set a persistent admin password here if you want to skip through the startup.

IF NOT DEFINED PsExecPath GOTO localhandle
IF /I "%~1"=="local" GOTO localhandle
IF /I NOT "%~1"=="" GOTO namehandle
GOTO adminsplit

:localhandle
SET modes=local
SET NAME=localhost
SET skipuserpass=1
GOTO options

:namehandle
SET modes=remote
SET NAME=%1
SET skipuserpass=0
GOTO adminsplit

:adminsplit
IF !NeedAdmin!==1 GOTO checkadmin
IF !NeedAdmin!==0 GOTO notelevated

:checkadmin
WHOAMI /all | findstr S-1-16-12288 > nul

IF ERRORLEVEL 1 GOTO NotAdmin
ECHO Administrative permissions confirmed.
ECHO.

IF !skipuserpass!==1 GOTO begin

:getcreds
IF NOT DEFINED User (
  SET /P "InputUserName=Enter admin username or leave blank to grab from whoami: "
  IF /I "!InputUserName!"=="" (
    FOR /F "tokens=* USEBACKQ" %%U IN (`whoami`) DO SET "User=%%U"
  ) ELSE IF /I NOT "!InputUserName!"=="" SET "User=!InputUserName!"
) ELSE (
  SET /P "InputUserName=Enter admin username or leave blank to use saved username ^(!User!^): "
  IF /I NOT "!InputUserName!"=="" SET "User=!InputUserName!"
)

SET "PSCommand=powershell -Command "$pword = read-host 'Enter admin password or leave blank to use saved password' -AsSecureString ; ^
    $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
FOR /F "usebackq delims=" %%P IN (`%PSCommand%`) DO SET "InputPassword=%%P"
IF /I NOT "!InputPassword!"=="" SET "Pass=!InputPassword!"

SET creds=filled
GOTO begin

:NotAdmin
IF !NeedAdmin!==1 GOTO elevate
ECHO Administrative permissions are needed for some commands.
ECHO This tool can be run without administrative permissions, but some commands will be unavailable.
ECHO If you would like this setting to be persistent, please edit line 11 of this script.
ECHO.
CHOICE /C YN /M "Do you want to run without admin permissions? "
ECHO.

IF ERRORLEVEL 2 GOTO elevate
IF ERRORLEVEL 1 GOTO notelevated

:elevate
ECHO Using Powershell to elevate session.
ECHO.
Powershell.exe Start-process %0 -verb runas
POPD
ENDLOCAL
EXIT

:notelevated
ECHO Running without admin permissions.
ECHO.
GOTO begin

:clsbegin
CLS
IF DEFINED Logging goto openlog
GOTO begin

:openlog
START %CD%\log.txt
goto begin

:begin
TITLE Quick Command Tool - Target: No Target Selected
IF NOT DEFINED NAME SET NAME=localhost
SET /P NAME="Enter Computer Name or IP Address, or leave blank to target !NAME!: "
IF DEFINED Logging DEL /F %CD%\log.txt
IF NOT !NAME!==localhost GOTO flagswitch
IF !NAME!==localhost goto flagswitch2

:flagswitch
SET modes=remote
GOTO options

:flagswitch2
SET modes=local
GOTO options

:options
TITLE Quick Command Tool - Target: !NAME!
CLS

IF !modes!==local ECHO *** Quick Command Tool - Running in Local mode ***
IF !modes!==remote ECHO *** Quick Command Tool - Running in Remote mode ***
IF !modes!==remote ECHO *** Unless specified, all commands are automated and will use the computer name or IP address you entered. ***
IF !modes!==remote ECHO *** Please ensure the computer name or IP address is correct to prevent issues. ***
ECHO.
ECHO 1. Change target computer.
IF !modes!==local ECHO 2. Toggle mode. Current: Local (all commands in option 5 run on localhost without PsExec)
IF !modes!==remote ECHO 2. Toggle mode. Current: Remote (all commands in option 5 run on target with PsExec)
ECHO 3. View SystemInfo Menu.
ECHO 4. Ping target computer.
ECHO 5. Troubleshooting and common fixes.
ECHO 6. Enter your own command.
ECHO 7. Relaunch this script as admin.
ECHO 8. See more options.
ECHO 9. Exit the script.
ECHO 0. View additional information about this script.
ECHO.
ECHO For best results with PsExec commands, run this script as admin.
ECHO.
ECHO Target computer: !NAME!
ECHO.

CHOICE /N /C:1234567890 /M "Press the number that corresponds to your desired tool or command. "
ECHO.

IF ERRORLEVEL 10 GOTO info
IF ERRORLEVEL 9 GOTO close
IF ERRORLEVEL 8 GOTO page2
IF ERRORLEVEL 7 GOTO admin
IF ERRORLEVEL 6 GOTO write
IF ERRORLEVEL 5 GOTO troubleshooting
IF ERRORLEVEL 4 GOTO callping
IF ERRORLEVEL 3 GOTO sysinfo
IF ERRORLEVEL 2 GOTO toggle
IF ERRORLEVEL 1 GOTO clsbegin

:toggle
IF !modes!==local GOTO flagswitch
IF !modes!==remote GOTO flagswitch2

:admin
WHOAMI /all | findstr S-1-16-12288 > nul

IF ERRORLEVEL 1 GOTO elevate
ECHO You are already running this as administrator^^!
ECHO.
PAUSE
GOTO options

:info
ECHO.
ECHO The intent of this script is to make interaction with the command line faster and more efficient, to streamline troubleshooting processes.
ECHO The latest version of this script can always be found at: https://github.com/memdev0/Quick-Command-Tool/
ECHO.
ECHO Thank you for using the Quick Command Tool^^!
ECHO If you found this script useful, please consider donating some Bitcoin to the address below.
ECHO Tips are not required, but are greatly appreciated. Thank you for supporting development of the Quick Command Tool^^!
ECHO.
ECHO BTC Address: 1N3HfM4wYu14MEQ5vRiDjpkBgZHg59NrUQ
ECHO.
ECHO Press any key to return to main menu.
ECHO.
PAUSE
GOTO options

:write
SET /P CUSTOM="Which command would you like to run? "
ECHO.
!CUSTOM!
PAUSE
GOTO options

:troubleshooting
IF !modes!==remote (
IF NOT !creds!==filled GOTO getcreds
)
ECHO.
ECHO *** Troubleshooting and Common Fixes ***
ECHO 1. Define your own arguments to the command.
ECHO 2. Run gpupdate /force on target computer.
ECHO 3. Restart print spooler on target computer.
ECHO 4. Force reboot target PC.
ECHO 5. Lock target PC.
ECHO 6. Print a test page on desired printer.
ECHO 7. Run automated disk cleanup.
ECHO 8. Kill all running PsExec tasks on target.
ECHO 9. Enter your own PsKill command.
ECHO 0. Return to main menu.
ECHO.
IF NOT DEFINED PsExecPath ECHO No path specified for PsExec. Commands will be run on localhost.
IF !modes!==local ECHO Local mode is enabled. All commands will be run on localhost.
IF !modes!==remote QUERY user /server:!NAME!
ECHO.
CHOICE /N /C:1234567890 /M "Please select from the above options. "
ECHO.

IF ERRORLEVEL 10 GOTO options
IF ERRORLEVEL 9 GOTO pskill
IF ERRORLEVEL 8 GOTO killpsexec
IF ERRORLEVEL 7 GOTO cleanup
IF ERRORLEVEL 6 GOTO testpage
IF ERRORLEVEL 5 GOTO lock
IF ERRORLEVEL 4 GOTO reboot
IF ERRORLEVEL 3 GOTO spooler
IF ERRORLEVEL 2 GOTO defaultpsexec
IF ERRORLEVEL 1 GOTO custompsexec

:killpsexec
ECHO.
IF NOT DEFINED PsExecPath (
  ECHO No path specified for PsExec. Returning to previous menu.
  PAUSE
  goto troubleshooting
)
!PsExecPath!\pskill -t \\!NAME! psexesvc.exe
IF DEFINED Logging ECHO •Remotely ended active PsExec tasks on !NAME!. >> %CD%\log.txt
ECHO Ended active PsExec tasks on !NAME!.
PAUSE
GOTO options

:pskill
ECHO.
IF NOT DEFINED PsExecPath (
  ECHO No path specified for PsExec. Returning to previous menu.
  PAUSE
  goto troubleshooting
)
ECHO Pulling active tasks from target computer.
START cmd /c !PsExecPath!\psexec \\!NAME! tasklist ^& pause
SET /P TASK="Enter the full name and extension of the task you want to kill (example: outlook.exe): "
!PsExecPath!\pskill -t \\!NAME! !TASK!
IF DEFINED Logging ECHO •Remotely ended !TASK! on !NAME!. >> %CD%\log.txt
ECHO Remotely ended !TASK! on !NAME!.
PAUSE
GOTO options

:cleanup
ECHO.
IF !modes!==local (
  cleanmgr /AUTOCLEAN
  ECHO Disk cleanup started.
  PAUSE
  GOTO options
)
SET /P SESSION="Enter the ID of the session to run the command in: "
ECHO.
START !PsExecPath!\psexec -i !SESSION! \\!NAME! -u !User! -p !Pass! cleanmgr /AUTOCLEAN
IF DEFINED Logging ECHO •Ran remote disk cleanup. >> %CD%\log.txt
ECHO Remote disk cleanup started.
PAUSE
GOTO options

:testpage
ECHO.
IF !modes!==local (
  wmic printer list brief
  SET /P PRINTER="Enter the full name of the printer to send a test page to: "
  rundll32 printui.dll,PrintUIEntry /k /n "!PRINTER!"
  ECHO Test page has been sent.
  PAUSE
  GOTO options
)
SET /P SESSION="Enter the ID of the session to run the command in: "
ECHO.
!PsExecPath!\psexec \\!NAME! wmic printer list brief
ECHO.
SET /P PRINTER="Enter the full name of the printer to send a test page to: "
START !PsExecPath!\psexec -i !SESSION! \\!NAME! -u !User! -p !Pass! rundll32 printui.dll,PrintUIEntry /k /n "!PRINTER!"
IF DEFINED Logging ECHO •Printed test page and confirmed it printed successfully. >> %CD%\log.txt
ECHO Test page has been printed. Please confirm if it was successful.
PAUSE
GOTO options

:mapdrive
ECHO.
SET /P DPATH="Enter the full path to the share drive that needs to be mapped, including the double slashes: "
SET /P LABEL="Enter the letter you want to assign to the drive: "
IF !modes!==local (
  net use !LABEL!: !DPATH! /p:yes ^& pause
  ECHO Drive mapped.
  PAUSE
  GOTO options
)
SET /P SESSION="Enter the ID of the session to run the command in: "
ECHO.
ECHO Mapping drive now. Please confirm it was successful.
ECHO.
START cmd /c !PsExecPath!\psexec -i !SESSION! \\!NAME! -u !User! -p !Pass! net use !LABEL!: !DPATH! /p:yes ^& pause
IF DEFINED Logging ECHO •Remotely mapped !DPATH! on !NAME! and confirmed access. >> %CD%\log.txt
PAUSE
GOTO options

:lock
ECHO.
IF !modes!==local (
  C:\Windows\System32\rundll32.exe user32.dll,LockWorkStation
  ECHO Locked workstation.
  PAUSE
  GOTO options
)
SET /P SESSION="Enter the ID of the session to run the command in: "
ECHO.
ECHO Locking remote PC now.
ECHO.
START !PsExecPath!\psexec -s -i !SESSION! \\!NAME! C:\Windows\System32\rundll32.exe user32.dll,LockWorkStation
IF DEFINED Logging ECHO •Remotely locked !NAME! and having them unlock to clear cached credentials. >> %CD%\log.txt
PAUSE
GOTO options

:reboot
ECHO.
IF !modes!==local (
  shutdown /f /r
  ECHO Reboot started.
  PAUSE
  GOTO options
)
ECHO Rebooting remote PC now.
ECHO.
START !PsExecPath!\psexec \\!NAME! shutdown /f /r
IF DEFINED Logging ECHO •Reset !NAME!. >> %CD%\log.txt
PAUSE
GOTO options

:spooler
IF !modes!==local (
  NET stop spooler
  DEL %systemroot%\System32\spool\printers\* /Q
  net start spooler
  ECHO Print spooler restarted and print queue reset.
  PAUSE
  GOTO options
)
ECHO Restarting print spooler. This will take about one minute. The script will print a message to let you know when it is complete.
START !PsExecPath!\psexec \\!NAME! NET stop spooler
TIMEOUT /T 10 /NOBREAK
START !PsExecPath!\psexec \\!NAME! del %systemroot%\System32\spool\printers\* /Q
TIMEOUT /T 3 /NOBREAK
START !PsExecPath!\psexec \\!NAME! NET start spooler
TIMEOUT /T 50 /NOBREAK
ECHO Print spooler should now be restarted. Please check the PsExec windows to confirm there were no errors.
IF DEFINED Logging ECHO •Remotely restarted print spooler on !NAME! and printing a test page. >> %CD%\log.txt
PAUSE
GOTO options

:custompsexec
ECHO.
IF NOT DEFINED PsExecPath (
  ECHO No path specified for PsExec. Returning to previous menu.
  PAUSE
  goto troubleshooting
)
SET /P SESSION="Enter the ID of the session to run the command in: "
ECHO.
SET /P COMMAND="Please complete the command with your desired arguments: psexec \\!NAME! "
START !PsExecPath!\psexec -i !SESSION! \\!NAME! !COMMAND!
IF DEFINED Logging ECHO •Ran !COMMAND! on !NAME!. >> %CD%\log.txt
PAUSE
GOTO options

:defaultpsexec
ECHO.
IF NOT DEFINED PsExecPath (
  ECHO No path specified for PsExec. Returning to previous menu.
  PAUSE
  goto troubleshooting
)
START !PsExecPath!\psexec \\!NAME! gpupdate /force
ECHO Running gpupdate. Please check PsExec window to confirm there are no errors.
IF DEFINED Logging ECHO •Ran remote gpupdate on !NAME!. >> %CD%\log.txt
PAUSE
GOTO options

:callping
PING !NAME!
PAUSE
GOTO options

:sysinfo
ECHO.
ECHO *** SystemInfo Options ***
ECHO 1. Find last reboot time.
ECHO 2. See available memory.
ECHO 3. Return to main menu.
ECHO.
CHOICE /N /C:123 /M "Please select from the above options. "

IF ERRORLEVEL 3 GOTO options
IF ERRORLEVEL 2 GOTO memory
IF ERRORLEVEL 1 GOTO boottime

:memory
SYSTEMINFO /S !NAME! | FIND "Memory"
PAUSE
GOTO options

:boottime
SYSTEMINFO /S !NAME! | FIND "System Boot Time"
PAUSE
GOTO options

:lookup
NSLOOKUP !NAME!
PAUSE
GOTO options

:page2
ECHO.
ECHO *** Main Menu Page 2 ***
ECHO 1. Network Locations
ECHO 2. Open log file.
ECHO 3. Map a network drive.
ECHO 4. Run nslookup on target computer.
ECHO 5. Return to main menu.
ECHO.
CHOICE /N /C:12345 /M "Please select from the above options. "
ECHO.

IF ERRORLEVEL 5 GOTO options
IF ERRORLEVEL 4 GOTO lookup
IF ERRORLEVEL 3 GOTO mapdrive
IF ERRORLEVEL 2 GOTO viewlog
IF ERRORLEVEL 1 GOTO locations

:viewlog
START %CD%\log.txt
goto options

:locations
ECHO.
ECHO *** Network Locations ***
ECHO 1. Print Servers
ECHO 2. Network Drives
ECHO 3. Return to previous page.
ECHO.
ECHO This menu will automatically open the selected location in File Explorer.
ECHO.
CHOICE /N /C:123 /M "Please select from the above options. "
ECHO.

IF ERRORLEVEL 3 GOTO page2
IF ERRORLEVEL 2 GOTO drives
IF ERRORLEVEL 1 GOTO printservers

:printservers
ECHO.
ECHO *** Print Servers ***
ECHO.
ECHO 1. !p1!
ECHO 2. Return to previous page.
ECHO.
CHOICE /N /C:12 /M "Please select from the above options. "
ECHO.

IF ERRORLEVEL 2 GOTO locations
IF ERRORLEVEL 1 GOTO print1

:print1
START !p1!
GOTO options

:drives
ECHO.
ECHO *** Network Drives ***
ECHO.
ECHO 1. !d1!
ECHO 2. Return to previous page.
ECHO.
CHOICE /N /C:12 /M "Please select from the above options. "
ECHO.

IF ERRORLEVEL 2 GOTO locations
IF ERRORLEVEL 1 GOTO drive1

:drive1
START !d1!
GOTO options

:close
POPD
ENDLOCAL
EXIT
