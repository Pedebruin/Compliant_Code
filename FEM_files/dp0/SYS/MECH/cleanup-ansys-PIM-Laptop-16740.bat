@echo off
set LOCALHOST=%COMPUTERNAME%
if /i "%LOCALHOST%"=="PIM-Laptop" (taskkill /f /pid 8864)
if /i "%LOCALHOST%"=="PIM-Laptop" (taskkill /f /pid 16740)

del /F cleanup-ansys-PIM-Laptop-16740.bat
