@echo OFF
TITLE Quick Command Tool
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
COLOR B
SET PsExecPath=0
REM PsExecPath is only needed if you intend on using PsExec, otherwise this can be left alone.
SET ToolPath=0
REM ToolPath is necessary for the permission checker to function correctly. Please paste the full path to the folder that contains the Quick Command Tool.
REM SET NeedAdmin=0
REM Only set NeedAdmin to 0 if you will never need admin permissions for this tool. Conversely, setting to 1 will always auto-elevate it.

IF !NeedAdmin!==1 GOTO checkadmin
IF !NeedAdmin!==0 GOTO notelevated

ECHO Administrative permissions are needed for some commands.
ECHO This tool can be run without administrative permissions, but some commands will be unavailable.
ECHO If you would like this setting to be persistent, please edit line 9 of this script.
ECHO.
CHOICE /C YN /M "Do you want to run without admin permissions? "

IF ERRORLEVEL 2 GOTO :checkadmin
IF ERRORLEVEL 1 GOTO :notelevated

:checkadmin
WHOAMI /all | findstr S-1-16-12288 > nul

IF %errorlevel%==1 GOTO NotAdmin
ECHO Administrative permissions confirmed.
ECHO.
GOTO begin

:NotAdmin 
echo This command prompt is not elevated. Using Powershell to invoke UAC prompt.
ECHO.
IF !ToolPath!==0 goto SetToolPath
Powershell.exe Start-process !ToolPath!\commandtooltest.bat -verb runas
goto end

:SetToolPath
ECHO You did not set the path to the tool^^! Please edit line 7 of this script.
ECHO Alternatively, you can enter the path in the prompt below.
ECHO Please note that this will need to be set every time this is launched if the script is not edited.
ECHO If you selected this option by mistake, leave the field empty and press enter to continue without admin permissions.
ECHO.
SET /P ToolPath="Enter the full path to the folder that contains the Quick Command Tool: "
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

:options
CLS

ECHO *** Unless specified, all commands are automated and will use the computer name or IP address you entered. ***
ECHO *** Please ensure the computer name or IP address is correct to prevent issues. ***
ECHO.
ECHO 1. Change target computer
ECHO 2. nslookup
ECHO 3. Find last boot time with systeminfo
ECHO 4. Ping
ECHO 5. PsExec
ECHO 6. Custom command
ECHO 7. NYI
ECHO 8. More options (NYI)
ECHO 9. Exit the tool
ECHO.
ECHO If you are entering a custom command, the computer name in any command can be replaced with ^^!NAME^^! if desired.
ECHO For best results with PsExec commands, run this script as admin.
ECHO.
ECHO If you appreciate this tool and would like to leave me a tip, press 0 for information^^!
ECHO.
ECHO Target computer: !NAME!
ECHO.

CHOICE /N /C:1234567890 /M "Press the number that corresponds to your desired tool or command. "

IF ERRORLEVEL 10 GOTO donation
IF ERRORLEVEL 9 GOTO end
IF ERRORLEVEL 8 GOTO donation
IF ERRORLEVEL 7 GOTO donation
IF ERRORLEVEL 6 GOTO five
IF ERRORLEVEL 5 GOTO four
IF ERRORLEVEL 4 GOTO three
IF ERRORLEVEL 3 GOTO two
IF ERRORLEVEL 2 GOTO one
IF ERRORLEVEL 1 GOTO clsbegin

:donation
ECHO.
ECHO.
ECHO I accept tips in Bitcoin, Ethereum, Litecoin or Monero. Tips are not required, but are very greatly appreciated^^!
ECHO.
ECHO BTC Address: 1KKBM6veHo78Mt7eejvp3nbCSHmA2YzDwp
ECHO ETH Address: 0x13d4Df2395c5366BEEc8F624dBba884a61401372
ECHO LTC Address: LfUi1LRDyEWFcg4dq6AS9SJ7pm93WZrtN4
ECHO XMR Address: 431uwg8s3bHR5YdkPU1TtsUZHkepQb5Ar3XaLEQU44NvdJhDNQF3L6nWMRwJ2VQiQxQexAUQtuCdxG3njeZTXh7qSN2VpBo
ECHO.
ECHO Press any key to return to main menu.
ECHO.
PAUSE
GOTO options

:five
SET /P CUSTOM="Which command would you like to run? "
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
ECHO 4. Return to main menu.
ECHO.
CHOICE /N /C:1234 /M "Please select from the above options. "

IF ERRORLEVEL 4 GOTO options
IF ERRORLEVEL 3 GOTO spooler
IF ERRORLEVEL 2 GOTO defaultpsexec
IF ERRORLEVEL 1 GOTO custompsexec

:oops
ECHO.
ECHO You did not set a path for PsExec^^! Please edit line 5 of this script with the path to your PSTools folder.
ECHO.
PAUSE
GOTO options

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
SYSTEMINFO /S !NAME! | FIND "System Boot Time"
PAUSE
GOTO options

:one
NSLOOKUP !NAME!
PAUSE
GOTO options
