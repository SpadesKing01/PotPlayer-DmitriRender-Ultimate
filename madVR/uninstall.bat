@cd /d "%~dp0"
@regsvr32.exe madVR.ax /u /s
@if not errorlevel 0 goto error
@Start /w madHcCtrl.exe quit
@if not exist "%SystemRoot%\SysWOW64\cmd.exe" goto success
@regsvr32.exe madVR64.ax /u /s
:success
@echo.
@echo.
@echo    Uninstallation succeeded.
@echo.
@goto done
:error
@echo.
@echo.
@echo    Uninstallation failed.
@echo.
@echo    You need to right click "uninstall.bat" and choose "run as admin".
@echo.
:done
@pause >NUL
