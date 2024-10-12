@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

SET "current_dir=%~dp0%"

:: %1 - project_name
:: %2 - build_dir
:: %3 - itch.io branch

:: Set variables
SET "root_dir=%current_dir%"
for %%a in ("%root_dir%..") do set "root_dir=%%~fa"
SET "output_dir=%current_dir%\output"
SET "build_dir=%root_dir%\%2"
SET "itchio_game_dir=%output_dir%\itchio_game"
SET "project_name=%1"
SET "itchio_branch=%3"

:: Create output folder
IF NOT EXIST "%output_dir%" (
    MKDIR "%output_dir%"
)

:: Create target folder
IF EXIST "%itchio_game_dir%" (
    RMDIR /s /q "%itchio_game_dir%"
)
MKDIR "%itchio_game_dir%"

:: Read ProjectVersion from file
FOR /F "tokens=2 delims==" %%a IN ('findstr "ProjectVersion=" "!root_dir!\Config\DefaultGame.ini"') DO (
    SET "project_version=%%a"
)
SET "itchio_branch=%itchio_branch%:!PROJECT_VERSION!"
ECHO !project_version!

:: Copy files
FOR /r "%build_dir%" %%f IN (*) DO (
    SET "source_file_path=%%~pnxf"
    SET "relative_path=%%~dpf"
    SET "relative_path=!relative_path:%build_dir%=!"
    SET "dest_file_path=%itchio_game_dir%\!relative_path!"

    :: Create necessary folders
    MKDIR "!dest_file_path!" >nul 2>&1

    :: Copy file
    COPY "%%f" "!dest_file_path!" >nul
)

:: Rename files
FOR /r "%itchio_game_dir%" %%f IN (*.pak *.sig *.ucas *.utoc) DO (
    SET "file_name=%%~nf"
    SET "file_name=!file_name:-Windows=!"
    SET "file_name=!file_name:%project_name%=!"
    SET "file_name=!file_name: =!"

    SET "file_path=%%~dpf"
    REN "%%f" "!file_name!%%~xf"
)

:: Delete unnecessary files
FOR /r "%itchio_game_dir%" %%f IN (Manifest_*_Win64.txt *.pdb) DO (
    DEL "%%f"
)

:: Run itch.io command
%current_dir%\itchio-sdk\butler.exe push !itchio_game_dir! !itchio_branch!
:: ECHO devops\itchio-sdk\butler.exe push +login !itchio_game_dir! !itchio_branch!

EXIT
