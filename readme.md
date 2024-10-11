# Unreal Engine Build Deployment Script Set for Steam and Itch.io

A set of scripts for automatically deploying Unreal Engine builds to Steam and Itch.io.  
Can be used with Jenkins or standalone.

## What do the scripts do?

1. Copy files from the source folder to `output/folder`
2. Remove `.pdb` and manifest files
3. Clean up extra files from `*.pak`, `*.sig`, `*.ucas`, `*.utoc`
4. Upload the build to Itch.io with the version specified in `project_version`
5. Upload the build to Steam using `login + password + Steam Guard code`, and publish it

## Setup

1. The project path should not contain spaces, for example: `D:\UE_Projects\MyGame`
2. Create a `devops` folder inside your project, so it looks like this: `D:\UE_Projects\MyGame\devops`
3. Download and extract the archive contents into `devops`, it should look like this:
   `D:\UE_Projects\MyGame\devops\deploy.bat`
4. For Steam, download the [Steam SDK](https://partner.steamgames.com/downloads/list) from
   the [Steamworks](https://partner.steamgames.com/doc/sdk)
   site // [steamworks_sdk_160.zip](https://partner.steamgames.com/downloads/steamworks_sdk_160.zip)
5. For Itch.io, download [Butler](https://itch.io/butler)
6. For 2FA authorization, you need a CLI script for generating the
   code [Steam-2FA-Generator](https://github.com/NeilMooreQ/Steam-2FA-Generator) and place file `steam-2fa-generator.exe` in `devops` folder, or you can
   use [steamguard-cli](https://github.com/dyc3/steamguard-cli) and modify `deploy_steam.bat`
7. In the folder `devops/steam-depods`, create a folder with the same name as your `.uproject` file, for example:
   `D:\UE_Projects\MyGame\devops\steam-depods\MyGame\`
8. Copy `app_480.vdf` and `depot_480.vdf` from `devops/steam-depods/Spacewar` to your folder
   `devops\steam-depods\MyGame\`
9. Replace all instances of `480` with your AppId from Steamworks

## Command-line Parameters

`--with_steam=1` - Upload build to Steam  
`--with_itchio=1` - Upload build to Itch.io  
`--project_name=Spacewar` - Project name from `.uproject`  
`--build_dir=Saved\StagedBuilds\Windows\` - Relative path from the root of the game to the build files  
`--steam_appid=430` - AppId from Steamworks  
`--steam_login=YOUR_STEAM_LOGIN` - Developer Steam account login  
`--steam_password=YOUR_STEAM_PASSWORD` - Developer Steam account password  
`--steam_secret_key=YOUR_SECRET_BASE32` - Secret key obtained via Steam Authenticator  
`--itchio_branch=YOUR_ITCHIO_NICKNAME/YOUR_ITCHIO_PROJECT_NAME` - Branch on Itch.io

## Deployment Steps

1. Open the `devops` folder and launch the Terminal
2. Enter the following command:

```Batch
deploy.bat --with_steam=1 --with_itchio=1 --project_name=Spacewar --build_dir=Saved\StagedBuilds\Windows\ --steam_appid=430 --steam_login=YOUR_STEAM_LOGIN --steam_password=YOUR_STEAM_PASSWORD --steam_secret_key=YOUR_SECRET_BASE32 --itchio_branch=YOUR_ITCHIO_NICKNAME/YOUR_ITCHIO_PROJECT_NAME 
```

3. During the first deployment, Butler may ask for authorization for Itch.io, but it won't be needed on subsequent runs.
4. ???
5. Profit!!!
