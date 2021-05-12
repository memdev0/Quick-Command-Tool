@echo OFF
TITLE Quick Command Tool - Target: No Target Selected
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
COLOR B

SET PsExecPath=0
REM PsExecPath is only needed if you intend on using PsExec, otherwise this can be left alone.

SET ToolPath=0
REM ToolPath is necessary for the permission checker to function correctly. Please paste the full path to the folder that contains the Quick Command Tool.

REM SET NeedAdmin=0
REM Only set NeedAdmin to 0 if you will never need admin permissions for this tool. Conversely, setting to 1 will always auto-elevate it.

IF !NeedAdmin!==1 GOTO elevate
IF !NeedAdmin!==0 GOTO notelevated

WHOAMI /all | findstr S-1-16-12288 > nul

IF ERRORLEVEL 1 GOTO NotAdmin
ECHO Administrative permissions confirmed.
ECHO.
GOTO begin

:NotAdmin 
ECHO Administrative permissions are needed for some commands.
ECHO This tool can be run without administrative permissions, but some commands will be unavailable.
ECHO If you would like this setting to be persistent, please edit line 9 of this script.
ECHO.
CHOICE /C YN /M "Do you want to run without admin permissions? "
ECHO.

IF ERRORLEVEL 2 GOTO elevate
IF ERRORLEVEL 1 GOTO notelevated

:elevate
ECHO Using Powershell to elevate session.
ECHO.
IF !ToolPath!==0 goto SetToolPath
Powershell.exe Start-process !ToolPath!\commandtooltest.bat -verb runas
goto end

:SetToolPath
ECHO You did not set the path to the tool^^! Please edit line 7 of this script.
ECHO.
ECHO Alternatively, you can enter the path in the prompt below.
ECHO.
ECHO Please note that this will need to be set every time this is launched if the script is not edited.
ECHO If you selected this option by mistake, leave the field empty and press enter to continue without admin permissions.
ECHO.
SET /P ToolPath="Enter the full path to the folder that contains the Quick Command Tool: "
ECHO.

IF !ToolPath!==0 goto notelevated
goto NotAdmin

:notelevated
ECHO Running without admin permissions.
ECHO.
GOTO begin

:clsbegin
CLS
GOTO begin

:begin
SET NAME=0
SET /P NAME="Enter Computer Name or IP Address (leave blank and press enter to end this script): "
IF !NAME!==0 GOTO end
TITLE Quick Command Tool - Target: !NAME!
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
ECHO 6. Run a custom command.
ECHO 7. Relaunch this script as admin.
ECHO 8. More options (NYI)
ECHO 9. Exit the script.
ECHO 0. View additional information about this script.
ECHO.
ECHO If you are entering a custom command, the computer name in any command can be replaced with ^^!NAME^^! if desired.
ECHO For best results with PsExec commands, run this script as admin.
ECHO.
ECHO Target computer: !NAME!
ECHO.

CHOICE /N /C:1234567890 /M "Press the number that corresponds to your desired tool or command. "
ECHO.

IF ERRORLEVEL 10 GOTO info
IF ERRORLEVEL 9 GOTO end
IF ERRORLEVEL 8 GOTO info
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
ECHO 5. Return to main menu.
ECHO.
CHOICE /N /C:12345 /M "Please select from the above options. "
ECHO.

IF ERRORLEVEL 5 GOTO options
IF ERRORLEVEL 4 GOTO reboot
IF ERRORLEVEL 3 GOTO spooler
IF ERRORLEVEL 2 GOTO defaultpsexec
IF ERRORLEVEL 1 GOTO custompsexec

:reboot
ECHO.
ECHO Rebooting remote PC now.
ECHO.
START !PsExecPath!\psexec \\!NAME! shutdown /f /r
PAUSE
GOTO options

:oops
ECHO You did not set a path for PsExec^^! Please edit line 5 of this script with the path to your PSTools folder.
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
START !PsExecPath!\psexec \\!NAME! NET start spooler
TIMEOUT /T 50 /NOBREAK
ECHO Print spooler should now be restarted. Please check the PsExec windows to confirm there were no errors.
PAUSE
GOTO options

:custompsexec
SET /P COMMAND="Please complete the command with your desired arguments: psexec \\!NAME! "

START !PsExecPath!\psexec \\!NAME! !COMMAND!
PAUSE
GOTO options

:defaultpsexec
START !PsExecPath\psexec \\!NAME! gpupdate /force
ECHO Running gpupdate. Please check PsExec window to confirm there are no errors.
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
