@echo off
set LOCALHOST=%COMPUTERNAME%
if /i "%LOCALHOST%"=="PIM-Laptop" (taskkill /f /pid 6316)
if /i "%LOCALHOST%"=="PIM-Laptop" (taskkill /f /pid 5956)

del /F cleanup-ansys-PIM-Laptop-5956.bat
