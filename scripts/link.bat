@echo Linking...

@ld65 -o %BUILD_DIR%\%OUT_NAME%.nes -C %SRC_DIR%\%CFG% %BUILD_DIR%\%MAIN%.o -m %BUILD_DIR%\%OUT_NAME%.map.txt -Ln %BUILD_DIR%\%OUT_NAME%.labels.txt --dbgfile %BUILD_DIR%\%OUT_NAME%.nes.dbg
@IF ERRORLEVEL 1 GOTO failure

@echo Linking successful.
@GOTO endbuild

:failure
@echo.
@echo Link error!

:endbuild
