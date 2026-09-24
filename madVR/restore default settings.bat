@echo off
echo.
echo.
title restore madVR default settings...
start /min reg delete HKEY_CURRENT_USER\Software\madshi\madVR /f
if exist "settings.bin" (
  if exist "settings.bak" (del settings.bak >NUL)
  rename settings.bin settings.bak >NUL)
echo    settings were reset to default
echo.
pause >NUL
