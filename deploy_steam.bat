@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
CD ..
SET "current_dir=%cd%"

:: %1 - project_name 
:: %2 - build_dir 
:: %3 - steam_appid 
:: %4 - steam_login 
:: %5 - steam_password 
:: %6 - steam_secret_key 

:: Set variables
SET "project_name=%1"
SET "root_dir=%cd%"
SET "output_dir=%root_dir%\devops\output"
SET "build_dir=%root_dir%\%2"

SET "steam_appid=%3"
SET "steam_login=%4"
SET "steam_password=%5"
SET "steam_secret_key=%6"

SET "steam_game_dir=%output_dir%\steam_!steam_appid!"
SET "steam_drm_dir=%output_dir%\steam_drm"

:: Create output folder
IF NOT EXIST "%output_dir%" (
    MKDIR "%output_dir%"
)

:: Create target folder
IF EXIST "%steam_game_dir%" (
    RMDIR /s /q "%steam_game_dir%"
)
MKDIR "%steam_game_dir%"

:: Read ProjectVersion from file
FOR /F "tokens=2 delims==" %%a IN ('findstr "ProjectVersion=" "!root_dir!\Config\DefaultGame.ini"') DO (
    SET "project_version=%%a"
)
ECHO !project_version!

:: Copy files
FOR /r "%build_dir%" %%f IN (*) DO (
    SET "source_file_path=%%~pnxf"
    SET "relative_path=%%~dpf"
    SET "relative_path=!relative_path:%build_dir%=!"
    SET "dest_file_path=%steam_game_dir%\!relative_path!"

    :: Create necessary folders
    MKDIR "!dest_file_path!" >nul 2>&1

    :: Copy file
    COPY "%%f" "!dest_file_path!" >nul
)

MKDIR "%steam_drm_dir%" >nul 2>&1

:: Move executable for DRM
IF EXIST "%steam_game_dir%\!project_name!\Binaries\Win64\!project_name!-Win64-Shipping.exe" (
    MOVE /y "%steam_game_dir%\!project_name!\Binaries\Win64\!project_name!-Win64-Shipping.exe" "%steam_drm_dir%\!project_name!-Win64-Shipping.exe"
)
IF EXIST "%steam_game_dir%\!project_name!.exe" (
    MOVE /y "%steam_game_dir%\!project_name!.exe" "%steam_drm_dir%\!project_name!.exe"
)

:: Rename files
FOR /r "%steam_game_dir%" %%f IN (*.pak *.sig *.ucas *.utoc) DO (
    SET "file_name=%%~nf"
    SET "file_name=!file_name:-Windows=!"
    SET "file_name=!file_name:%project_name%=!"
    SET "file_name=!file_name: =!"

    SET "file_path=%%~dpf"
    REN "%%f" "!file_name!%%~xf"
)

:: Delete unnecessary files
FOR /r "%steam_game_dir%" %%f IN (Manifest_*_Win64.txt *.pdb) DO (
    DEL "%%f"
)

:: Generate 2FA code
FOR /f "delims=" %%a IN ('devops\steam-2fa-generator.exe --secret_key !steam_secret_key!') DO (
    SET "steam_2fa_code=%%a"
)

SET "drm_args=+drm_wrap !steam_appid! "%steam_drm_dir%\!project_name!.exe" "%steam_game_dir%\!project_name!.exe" drmtoolp 0 +drm_wrap !steam_appid! "%steam_drm_dir%\!project_name!-Win64-Shipping.exe" "%steam_game_dir%\!project_name!\Binaries\Win64\!project_name!-Win64-Shipping.exe" drmtoolp 6"
SET "content_args=+run_app_build ..\..\..\..\..\devops\steam-depods\!project_name!\app_!steam_appid!.vdf"
SET "steam_cmd_args=!drm_args! !content_args! +quit"

:: Run steamcmd
START /WAIT devops\steam-sdk\tools\ContentBuilder\builder\steamcmd.exe +login !steam_login! !steam_password! !steam_2fa_code! !steam_cmd_args!
:: ECHO devops\steam-sdk\tools\ContentBuilder\builder\steamcmd.exe +login !steam_login! !steam_password! !steam_2fa_code! !steam_cmd_args!

EXIT
