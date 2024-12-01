@set ENV_FILE=.env

@if not exist "%ENV_FILE%" (
    @echo ERROR: .env file not found. Aborting.
    @exit /b 1
)

@for /f "tokens=1,2 delims==" %%A in (%ENV_FILE%) do @set "%%A=%%B"

@set WORKSPACE_DIR=%~dp0%

@call scripts/cleanup.bat
@if %errorlevel% neq 0 exit /b %errorlevel%

@call scripts/assemble.bat
@if %errorlevel% neq 0 exit /b %errorlevel%

@call scripts/lint.bat
@if %errorlevel% neq 0 exit /b %errorlevel%

@call scripts/link.bat
@if %errorlevel% neq 0 exit /b %errorlevel%

@echo Build successful, output to: %NES_BUILD_DIR%\%NES_OUT_NAME%.nes
