@echo OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
TITLE Quick Command Tool - Target: No Target Selected
COLOR B
CLS
@pushd %~dp0

SET PsExecPath=0
REM PsExecPath is only needed if you intend on using PsExec, otherwise this can be left alone.

SET NeedAdmin=1
REM Only set NeedAdmin to 0 if you will never need admin permissions for this tool. Conversely, setting to 1 will always auto-elevate it.

SET Logging=on
REM Experimental feature to automatically write ticket notes. Enter anything here to enable it, or put REM in front of it to disable it.

SET p1=0
SET d1=0
REM These will set network locations. p# for print servers and d# for shared drives. Will automatically open when selected. Can be scaled as needed.

SET User=
REM Set a persistent admin username here if you want to skip through the startup.

SET Pass=
REM Set a persistent admin password here if you want to skip through the startup.

IF !NeedAdmin!==1 GOTO checkadmin
IF !NeedAdmin!==0 GOTO notelevated

:checkadmin
WHOAMI /all | findstr S-1-16-12288 > nul

IF ERRORLEVEL 1 GOTO NotAdmin
ECHO Administrative permissions confirmed.
ECHO.

IF NOT DEFINED User (
  SET /P "InputUserName=Enter admin username or leave blank to grab from whoami: "
  IF /I "!InputUserName!"=="" (
    FOR /F "tokens=* USEBACKQ" %%U IN (`whoami`) DO SET "User=%%U"
  ) ELSE IF /I NOT "!InputUserName!"=="" SET "User=!InputUserName!"
) ELSE (
  SET /P "InputUserName=Enter admin username or leave blank to use saved variable ^(!User!^): "
  IF /I NOT "!InputUserName!"=="" SET "User=!InputUserName!"
)

SET "PSCommand=powershell -Command "$pword = read-host 'Enter admin password or leave blank to use saved variable' -AsSecureString ; ^
    $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
FOR /F "usebackq delims=" %%P IN (`%PSCommand%`) DO SET "InputPassword=%%P"
IF /I NOT "!InputPassword!"=="" SET "Pass=!InputPassword!"

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
goto close

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
SET NAME=localhost
SET /P NAME="Enter Computer Name or IP Address (leave blank and press enter to target localhost): "
TITLE Quick Command Tool - Target: !NAME!
IF DEFINED Logging DEL /F %CD%\log.txt
GOTO options

:options
CLS

ECHO *** Unless specified, all commands are automated and will use the computer name or IP address you entered. ***
ECHO *** Please ensure the computer name or IP address is correct to prevent issues. ***
ECHO.
ECHO 1. Change target computer.
ECHO 2. Run nslookup on target computer.
ECHO 3. View SystemInfo Menu.
ECHO 4. Ping target computer.
ECHO 5. View PsExec Menu.
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
IF ERRORLEVEL 7 GOTO six
IF ERRORLEVEL 6 GOTO five
IF ERRORLEVEL 5 GOTO four
IF ERRORLEVEL 4 GOTO three
IF ERRORLEVEL 3 GOTO two
IF ERRORLEVEL 2 GOTO one
IF ERRORLEVEL 1 GOTO clsbegin

:six
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

:five
SET /P CUSTOM="Which command would you like to run? "
ECHO.
!CUSTOM!
PAUSE
GOTO options

:four
if !PsExecPath!==0 GOTO oops

ECHO.
ECHO *** PsExec Options ***
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
QUERY user /server:!NAME!
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
!PsExecPath!\pskill -t \\!NAME! psexesvc.exe
IF DEFINED Logging ECHO •Remotely ended active PsExec tasks on !NAME!. >> %CD%\log.txt
ECHO Ended active PsExec tasks on !NAME!.
PAUSE
GOTO options

:pskill
ECHO.
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
SET /P SESSION="Enter the ID of the session to run the command in: "
ECHO.
START !PsExecPath!\psexec -i !SESSION! \\!NAME! -u !User! -p !Pass! cleanmgr /AUTOCLEAN
IF DEFINED Logging ECHO •Ran remote disk cleanup. >> %CD%\log.txt
ECHO Remote disk cleanup started.
PAUSE
GOTO options

:testpage
ECHO.
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
SET /P SESSION="Enter the ID of the session to run the command in: "
ECHO.
ECHO Mapping drive now. Please confirm it was successful.
ECHO.
START cmd /c !PsExecPath!\psexec -i !SESSION! \\!NAME! -u !User! -p !Pass! net use !LABEL!: !DPATH! /p:yes ^& pause
IF DEFINED Logging ECHO •Remotely mapped !DPATH! on !NAME! and confirmed access. >> %CD%\log.txt
PAUSE
GOTO options

:lock
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
ECHO Rebooting remote PC now.
ECHO.
START !PsExecPath!\psexec \\!NAME! shutdown /f /r
IF DEFINED Logging ECHO •Reset !NAME!. >> %CD%\log.txt
PAUSE
GOTO options

:oops
ECHO You did not set a path for PsExec^^! Please edit line 8 of this script with the path to your PSTools folder.
ECHO.
ECHO Alternatively, you can enter the path in the prompt below.
ECHO Please note that this will need to be set every time this is launched if the script is not edited.
ECHO If you selected this option by mistake, leave the field empty and press enter to return to the main menu.
ECHO.
SET /P PsExecPath="Enter the full path to the PSTools folder: "
ECHO.

IF !PsExecPath!==0 GOTO options
GOTO four

:spooler
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
SET /P SESSION="Enter the ID of the session to run the command in: "
ECHO.
SET /P COMMAND="Please complete the command with your desired arguments: psexec \\!NAME! "
START !PsExecPath!\psexec -i !SESSION! \\!NAME! !COMMAND!
IF DEFINED Logging ECHO •Ran !COMMAND! on !NAME!. >> %CD%\log.txt
PAUSE
GOTO options

:defaultpsexec
START !PsExecPath!\psexec \\!NAME! gpupdate /force
ECHO Running gpupdate. Please check PsExec window to confirm there are no errors.
IF DEFINED Logging ECHO •Ran remote gpupdate on !NAME!. >> %CD%\log.txt
PAUSE
GOTO options

:three
PING !NAME!
PAUSE
GOTO options

:two
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

:one
NSLOOKUP !NAME!
PAUSE
GOTO options

:page2
ECHO.
ECHO *** Main Menu Page 2 ***
ECHO 1. Network Locations
ECHO 2. Open log file.
ECHO 3. Map a network drive.
ECHO 4. Return to main menu.
ECHO.
CHOICE /N /C:1234 /M "Please select from the above options. "
ECHO.

IF ERRORLEVEL 4 GOTO options
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
popd
exit
