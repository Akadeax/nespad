@echo Linting...
@echo on
@"scripts/6502Linter.exe" "%SRC_DIR%/%MAIN%.s" "zp_temp_x"
@echo off

@IF ERRORLEVEL 1 GOTO failure
@echo Linted successfully.
@GOTO endbuild

:failure
@echo Linting error!

:endbuild
