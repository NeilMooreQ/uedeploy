@ECHO OFF

SET "current_dir=%~dp0%"
SET "with_steam=false"
SET "with_itchio=false"

cd %current_dir%;

:loop
IF NOT "%1"=="" (
    :: Check if Steam upload is required
    IF "%1"=="--with_steam" (
        SET "with_steam=true"
        SHIFT
    )

    :: Check if Itch.io upload is required
    IF "%1"=="--with_itchio" (
        SET "with_itchio=true"
        SHIFT
    )

    :: Set project name directory
    IF "%1"=="--project_name" (
        SET "project_name=%2"
        SHIFT
    )

    :: Set build directory
    IF "%1"=="--build_dir" (
        SET "build_dir=%2"
        SHIFT
    )

    :: Set Steam AppID and config
    IF "%1"=="--steam_appid" (
        SET "steam_appid=%2"
        SHIFT
    )

    :: Set Steam login credentials
    IF "%1"=="--steam_login" (
        SET "steam_login=%2"
        SHIFT
    )
    IF "%1"=="--steam_password" (
        SET "steam_password=%2"
        SHIFT
    )
    IF "%1"=="--steam_secret_key" (
        SET "steam_secret_key=%2"
        SHIFT
    )

    :: Set Itch.io branch
    IF "%1"=="--itchio_branch" (
        SET "itchio_branch=%2"
        SHIFT
    )

    SHIFT
    GOTO :loop
)

IF NOT "%with_steam%"=="false" (
    ECHO Uploading to Steam...
    "%current_dir%\deploy_steam.bat" %project_name% %build_dir% %steam_appid% %steam_login% %steam_password% %steam_secret_key%
)

IF NOT "%with_itchio%"=="false" (
    ECHO Uploading to Itch.io...
	echo "%current_dir%\deploy_itchio.bat"
    "%current_dir%\deploy_itchio.bat" %project_name% %build_dir% %itchio_branch%
)
