@echo off
set LOCALHOST=%COMPUTERNAME%
if /i "%LOCALHOST%"=="PIM-Laptop" (taskkill /f /pid 5268)
if /i "%LOCALHOST%"=="PIM-Laptop" (taskkill /f /pid 1728)

del /F cleanup-ansys-PIM-Laptop-1728.bat
