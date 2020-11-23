@echo off
set LOCALHOST=%COMPUTERNAME%
if /i "%LOCALHOST%"=="PIM-Laptop" (taskkill /f /pid 20192)
if /i "%LOCALHOST%"=="PIM-Laptop" (taskkill /f /pid 12092)

del /F cleanup-ansys-PIM-Laptop-12092.bat
