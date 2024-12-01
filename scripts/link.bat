@echo Linking...

@ld65 -o %NES_BUILD_DIR%\%NES_OUT_NAME%.nes -C %NES_SRC_DIR%\%NES_CFG% %NES_BUILD_DIR%\%NES_MAIN%.o -m %NES_BUILD_DIR%\%NES_OUT_NAME%.map.txt -Ln %NES_BUILD_DIR%\%NES_OUT_NAME%.labels.txt --dbgfile %NES_BUILD_DIR%\%NES_OUT_NAME%.nes.dbg
@IF ERRORLEVEL 1 GOTO failure

@echo Linking successful.
@GOTO endbuild

:failure
@echo.
@echo Link error!

:endbuild
