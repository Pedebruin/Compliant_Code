@echo off
set LOCALHOST=%COMPUTERNAME%
if /i "%LOCALHOST%"=="PIM-Laptop" (taskkill /f /pid 24260)
if /i "%LOCALHOST%"=="PIM-Laptop" (taskkill /f /pid 23248)

del /F cleanup-ansys-PIM-Laptop-23248.bat
