# [FOR 3.8] Alternative Guide

## Requirement
- NOT YET uninstall WUWA on Steam
- NOT YET updated WUWA on Steam to version 3.8
- ALREADY updated WUWA on Launcher (non-Steam) to version 3.8

## Procedure
1. In the *wuwa-steam-quick-install-uninstall.ps1* script (see [Usage](https://github.com/DOTzX/wuwa-steam-quick-install-uninstall#usage) below), perform **Safe Uninstall only**:
```text
"Is the Official Launcher ready to start the game and has finished updating?" Answer YES
"Is Wuthering Waves still installed on Steam?" Answer YES
```
2. After that, **DO NOT uninstall** WUWA through Steam. Instead, update it directly through Steam.
3. Make sure the following files **EXIST**:
```text
Wuthering Waves Game\Client\Binaries\Win64\steam_api64.dll
Wuthering Waves Game\Client\Binaries\Win64\steam_appid.txt
Wuthering Waves Game\Client\Binaries\Win64\ThirdParty\KrPcSdk_Global\steam_api64.dll
Wuthering Waves Game\Client\Binaries\Win64\ThirdParty\KrPcSdk_Global\steam_appid.txt
```
> Alternatively, download my [**__*Client.zip*__**](https://github.com/DOTzX/wuwa-steam-quick-install-uninstall/blob/master/Client.zip).
4. Change WUWA's Steam Launch Options:
```
"path\to\Client-Win64-Shipping.exe" -krqlv=sd -SkipSplash %command%
```
- Replace `path\to` with the actual location of `Client-Win64-Shipping.exe`.
- Replace `-krqlv=sd` with either `-krqlv=hd` or `-krqlv=uhd` (match yours downloaded package)

5. Done

.

.

.

# [NOT WORK IN 3.8] Pre-Download WUWA on Steam using Launcher

## Requirement
- Wuthering Waves on Steam is not installed
- Official Launcher ready to start the game and has finished updating
- Official Launcher and Steam version must be on an NTFS file system (can be on a different drive)
- Administrative privileges are required because the script uses symlinks
- As of Wuthering Waves 3.7, required Resource is **HD** for Steam version

## Procedure for upcoming pre-downloads
1. (When the pre-download period begins)
2. Pre-download the game through the launcher
3. (When maintenance begins)
4. Apply updates through the launcher
5. Perform a **SAFE UNINSTALL** of Wuthering Waves on Steam following this guide
6. Perform a **QUICK INSTALLATION** of Wuthering Waves on Steam following this guide

## Important notes after following this guide
- Pre-downloads must be done through the official launcher. This guide only facilitates the process on Steam.
- Automatic updates on Steam must be set to “Wait until I launch the game”, it prevents Steam from patching the official launcher files when a major update arrives.
- A safe uninstall is **MANDATORY** for each major version update.

## Usage

Choose one of the two options

### Option: Online
- Open PowerShell as Admin
- Copy-paste:
```
irm "https://raw.githubusercontent.com/DOTzX/wuwa-steam-quick-install-uninstall/refs/heads/master/wuwa-steam-quick-install-uninstall.ps1" | iex
```
- Follow the instructions provided

### Option: Offline
- Download directly from [here](https://github.com/DOTzX/wuwa-steam-quick-install-uninstall/archive/refs/heads/master.zip)
- Unpack
- Open the "open.bat"
- Follow the instructions provided

---
##### Support me: [saweria](https://saweria.co/dotx) / [ko-fi](https://ko-fi.com/dotx_exe) / [patreon](https://patreon.com/dotx) / [buy-me-a-coffee](https://buymeacoffee.com/dotx)
---

## Screenshot
<img width="987" height="909" alt="image" src="https://github.com/user-attachments/assets/055079f8-3aa7-43a1-91f7-8eb560a1a150" />

## Video
[![Pre-Download WUWA on Steam using Launcher](https://img.youtube.com/vi/kGagCyYDKg8/0.jpg)](https://www.youtube.com/watch?v=kGagCyYDKg8)
