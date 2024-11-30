@cd %WORKSPACE_DIR%
@mkdir %BUILD_DIR%
@echo Build directory created.
@echo Compiling...

@IF %ENABLE_TESTS%==true (
    @ca65 %SRC_DIR%\%MAIN%.s -g -o %BUILD_DIR%\%MAIN%.o -DTESTS
) ELSE (
    @ca65 %SRC_DIR%\%MAIN%.s -g -o %BUILD_DIR%\%MAIN%.o
)

@IF ERRORLEVEL 1 GOTO failure
@echo Compiled successfully.
@GOTO endbuild

:failure
@echo Compilation error!

:endbuild
