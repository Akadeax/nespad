@call scripts/cleanup.bat
@if %errorlevel% neq 0 exit /b %errorlevel%

@call scripts/assemble.bat
@if %errorlevel% neq 0 exit /b %errorlevel%

@call scripts/lint.bat
@if %errorlevel% neq 0 exit /b %errorlevel%

@call scripts/link.bat
@if %errorlevel% neq 0 exit /b %errorlevel%

@echo Build successful, output to: %BUILD_DIR%\%OUT_NAME%.nes
