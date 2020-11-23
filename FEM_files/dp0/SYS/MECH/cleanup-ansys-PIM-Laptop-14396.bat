@echo off
set LOCALHOST=%COMPUTERNAME%
if /i "%LOCALHOST%"=="PIM-Laptop" (taskkill /f /pid 4636)
if /i "%LOCALHOST%"=="PIM-Laptop" (taskkill /f /pid 14396)

del /F cleanup-ansys-PIM-Laptop-14396.bat
