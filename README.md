# Quick-Command-Tool
Batch script that streamlines common troubleshooting commands for Windows. Completely standalone, just save as a .bat file and run. Will be updating over time.

Known bugs:

1. Automatically launch script as admin will not work if the script is stored on a network drive. Potential solution is to include code to assign a temporary local drive letter to that specific location while the script is running, and to remove it when the script ends, but would need to alter how all exits are handled in order to cover this.
2. Output sometimes skips the pause due to the same issue that causes the auto-elevate to fail. Same potential solution.
3. Psexec output for gpupdate command in particular seems to be invisible when launched using this script, but only on virtual machines. Not really sure if this is something that can be fixed on my end as it occurs inside psexec.

Known softlocks:

1. Using any systeminfo command on a machine that is in the boot sequence will result in the script locking up. This can be corrected by using CTRL+C, and then pressing N to continue running the script.
