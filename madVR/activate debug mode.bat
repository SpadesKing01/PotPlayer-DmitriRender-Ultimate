@echo off
echo.
echo.

if "%~nx0"=="activate debug mode.bat" (title activate madVR debug mode...)
if "%~nx0"=="activate release mode.bat" (title activate madVR release mode...)

if not exist "madVR.ax" (goto noMadVR)
if exist "madVR [release].ax" (goto activateReleaseMode)
if exist "madVR [debug].ax" (goto activateDebugMode)

if "%~nx0"=="activate debug mode.bat" (echo    file "madVR [debug].ax" not found) else (
if "%~nx0"=="activate release mode.bat" (echo    file "madVR [release].ax" not found) else (echo    some files are missing))
echo.
pause >NUL
exit

:noMadVR
echo    file "madVR.ax" not found
echo.
pause >NUL
exit

:activateReleaseMode
title activate madVR release mode...
ren "madVR.ax" "madVR [debug].ax"
ren "madVR [release].ax" "madVR.ax"
ren "madVR64.ax" "madVR64 [debug].ax"
ren "madVR64 [release].ax" "madVR64.ax"
if exist "madVR [debug].ax" (echo    release mode was successfully activated) else (echo    activating release mode failed)
echo.
pause >NUL
if exist "madVR [debug].ax" (ren "%~nx0" "activate debug mode.bat")
exit

:activateDebugMode
title activate madVR debug mode...
ren "madVR.ax" "madVR [release].ax"
ren "madVR [debug].ax" "madVR.ax"
ren "madVR64.ax" "madVR64 [release].ax"
ren "madVR64 [debug].ax" "madVR64.ax"
if exist "madVR [release].ax" (echo    debug mode was successfully activated) else (echo    activating debug mode failed)
echo.
pause >NUL
if exist "madVR [release].ax" (ren "%~nx0" "activate release mode.bat")
exit
