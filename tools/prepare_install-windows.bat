@echo off
pushd %~dp0
set SCRIPT_ROOT=%CD%
popd

powershell.exe -executionpolicy RemoteSigned -file %SCRIPT_ROOT%\prepare_install-windows.ps1 %*

pause
