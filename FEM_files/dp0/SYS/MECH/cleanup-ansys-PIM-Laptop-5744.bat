@echo off
set LOCALHOST=%COMPUTERNAME%
if /i "%LOCALHOST%"=="PIM-Laptop" (taskkill /f /pid 26568)
if /i "%LOCALHOST%"=="PIM-Laptop" (taskkill /f /pid 5744)

del /F cleanup-ansys-PIM-Laptop-5744.bat
