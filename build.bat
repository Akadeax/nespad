@SET WORKSPACE_DIR=%~dp0

@SET BUILD_DIR=build
@SET SRC_DIR=src

@SET MAIN=main
@SET CFG=game.cfg
@SET CHR=game.chr
@SET OUT_NAME=Nespad

@call scripts/cleanup.bat
@if %errorlevel% neq 0 exit /b %errorlevel%

@call scripts/assemble.bat
@if %errorlevel% neq 0 exit /b %errorlevel%

@call scripts/lint.bat
@if %errorlevel% neq 0 exit /b %errorlevel%

@call scripts/link.bat
@if %errorlevel% neq 0 exit /b %errorlevel%

@echo Build successful, output to: %BUILD_DIR%\%OUT_NAME%.nes
