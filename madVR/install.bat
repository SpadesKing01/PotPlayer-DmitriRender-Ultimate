@cd /d "%~dp0"
@regsvr32.exe madVR.ax /s
@if not errorlevel 0 goto error
@if not exist "%SystemRoot%\SysWOW64\cmd.exe" goto success
@regsvr32.exe madVR64.ax /s
:success
@echo.
@echo.
@echo    Installation succeeded.
@echo.
@echo    Please do not delete the madVR folder.
@echo    The installer has not copied the files anywhere.
@echo.
@goto done
:error
@echo.
@echo.
@echo    Installation failed.
@echo.
@echo    You need to right click "install.bat" and choose "run as admin".
@echo.
:done
@pause >NUL
