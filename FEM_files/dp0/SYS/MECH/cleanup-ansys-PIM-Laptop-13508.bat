@echo off
set LOCALHOST=%COMPUTERNAME%
if /i "%LOCALHOST%"=="PIM-Laptop" (taskkill /f /pid 7204)
if /i "%LOCALHOST%"=="PIM-Laptop" (taskkill /f /pid 13508)

del /F cleanup-ansys-PIM-Laptop-13508.bat
