@cd %WORKSPACE_DIR%
@mkdir %NES_BUILD_DIR%
@echo Build directory created.
@echo Compiling...

@IF %ENABLE_TESTS%==true (
    @ca65 %NES_SRC_DIR%\%NES_MAIN%.s -g -o %NES_BUILD_DIR%\%NES_MAIN%.o -DTESTS
) ELSE (
    @ca65 %NES_SRC_DIR%\%NES_MAIN%.s -g -o %NES_BUILD_DIR%\%NES_MAIN%.o
)

@IF ERRORLEVEL 1 GOTO failure
@echo Compiled successfully.
@GOTO endbuild

:failure
@echo Compilation error!

:endbuild
