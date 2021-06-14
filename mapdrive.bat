@echo OFF
TITLE Network Drive Mapping Tool
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
COLOR B
CLS

SET d1=

:start
SET /P LABEL="Enter the letter you want to assign to the drive: "
CLS
GOTO page1

:page1
ECHO *** Network Drives ***
ECHO.
ECHO There are <x> network drives total. Please use the number keys to select your desired drive and it will automatically be mapped.
ECHO Your drive will be mapped with the letter !LABEL!.
ECHO.
ECHO 1. Example (!d1!)
ECHO 2. Exit this tool. 
ECHO.

CHOICE /N /C:12 /M "Press the number that corresponds to your desired network drive path. "
ECHO.

IF ERRORLEVEL 2 GOTO close
IF ERRORLEVEL 1 GOTO d1

:d1
net use !LABEL!: !d1! /p:yes
ECHO Mapped drive !d1! with label !LABEL!. Please test access to confirm.
pause
GOTO confirm

:confirm
CLS
CHOICE /C YN /M "Do you need to map another drive? " 

IF ERRORLEVEL 2 GOTO close
IF ERRORLEVEL 1 GOTO start

:close
exit
