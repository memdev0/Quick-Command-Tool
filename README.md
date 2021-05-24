# Quick-Command-Tool
Batch script that streamlines common troubleshooting commands for Windows. Completely standalone, just save as a .bat file and run. Will be updating over time.

Known issues:
1. When running this script on a VMWare virtual machine, input is sometimes duplicated, resulting in the output of some commands being erased before they can be read. This is an issue with VMWare in particular and is not an issue with the script, therefore there is nothing I can do to correct it.
2. Using any systeminfo command on a machine that is in the boot sequence will result in the script locking up. This can be corrected by using CTRL+C, and then pressing N to continue running the script.
3. Closing the script any other way than using the options built in will result in a temporary network drive being created, pointing to the location the script is running from. This is a feature of the script, and you can feel free to disconnect this drive, as it will re-create itself the next time the script runs. Exiting the script correctly will automatically unmap this drive.
