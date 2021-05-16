# Quick-Command-Tool
Batch script that streamlines common troubleshooting commands for Windows. Completely standalone, just save as a .bat file and run. Will be updating over time.

Known softlocks:

1. Using any systeminfo command on a machine that is in the boot sequence will result in the script locking up. This can be corrected by using CTRL+C, and then pressing N to continue running the script.
