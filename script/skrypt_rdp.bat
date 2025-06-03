@echo off
set "SCRIPT=C:\Users\RP\Desktop\RDP_remove_add.ps1"

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%SCRIPT%\"' -Verb RunAs"
exit
