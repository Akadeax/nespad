@set WORKSPACE_DIR=%cd%
@set ENV_FILE=%WORKSPACE_DIR%\.env

@if not exist "%ENV_FILE%" (
    @echo ERROR: .env file not found. Aborting. %ENV_FILE%
    @exit /b 1
)

@for /f "tokens=1,2 delims==" %%A in (%ENV_FILE%) do @set "%%A=%%B"

@set ROM_PATH=%WORKSPACE_DIR%\%NES_BUILD_DIR%\%NES_OUT_NAME%.nes

"scripts/tests/NESTestExplorer.exe" "%NES_PROGRAM% --testrunner %ROM_PATH% %WORKSPACE_DIR%/scripts/tests/tests_adapter.lua" "%WORKSPACE_DIR%/%TESTS_FILE%"
@exit /b %ERRORLEVEL%