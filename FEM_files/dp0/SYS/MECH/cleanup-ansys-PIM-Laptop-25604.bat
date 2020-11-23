@echo off
set LOCALHOST=%COMPUTERNAME%
if /i "%LOCALHOST%"=="PIM-Laptop" (taskkill /f /pid 21388)
if /i "%LOCALHOST%"=="PIM-Laptop" (taskkill /f /pid 25604)

del /F cleanup-ansys-PIM-Laptop-25604.bat
