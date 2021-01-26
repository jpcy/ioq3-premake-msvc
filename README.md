## ioq3-premake-msvc 

[![Actions Status](https://github.com/jpcy/ioq3-premake-msvc/workflows/build/badge.svg)](https://github.com/jpcy/ioq3-premake-msvc/actions) [![Appveyor CI Build Status](https://ci.appveyor.com/api/projects/status/github/jpcy/ioq3-premake-msvc?branch=master&svg=true)](https://ci.appveyor.com/project/jpcy/ioq3-premake-msvc)

A Premake script for generating Visual Studio projects for [ioquake3](https://github.com/ioquake/ioq3).

ioquake3 uses MinGW for Windows builds. There are Visual Studio projects in the offical repo, but they aren't maintained, and are incomplete and often broken.

![screenshot](https://github.com/jpcy/ioq3-premake-msvc/raw/master/screenshot.png)

## Instructions
1. Update submodules to get SDL. `git submodule update`
2. Clone [ioquake3](https://github.com/ioquake/ioq3) and this repository to the same parent directory.
3. Run `vs2015.bat`, `vs2017.bat` or `vs2019.bat`.
4. Open `build\vs201*\ioquake3.sln` in Visual Studio and compile.

The compiled binaries are written to `build\vs201*\bin_*`. You can either manually copy them to your Quake 3 directory and run the ioquake3 executable, or read the section [Debugging ioquake3](#debugging-ioquake3) below.

## Options
As an alternative to the batch files, invoke premake directly with `premake5 [options] [action]`, where [options] are one or more of the following, and [action] is either vs2015 or vs2017.

Option                    | Description
------------------------- | -------------------------------------
--disable-client          | Disable the ioquake3 project
--disable-server          | Disable the dedicated server project
--disable-baseq3          | Disable the baseq3 projects
--disable-missionpack     | Disable the missionpack projects
--disable-renderer-gl1    | Disable the OpenGL 1 renderer project
--disable-renderer-gl2    | Disable the OpenGL 2 renderer project
--disable-renderer-bgfx   | Disable the bgfx renderer project
--disable-game-dll        | Disable the game DLL projects
--disable-game-qvm        | Disable the game QVM projects
--disable-ogg             | Disable Ogg Opus and Vorbis support
--rename-baseq3=NAME      | Rename the baseq3 project
--rename-missionpack=NAME | Rename the missionpack project
--standalone              | Remove the dependency on Q3A

For example, run `premake5 --disable-baseq3 --disable-missionpack vs2017` if you don't want the game code projects.

## Debugging ioquake3
ioquake3 requires the baseq3 directory containing pak*.pk3 files to be in one of its search paths to run. The search paths are:

* fs_homepath - `%APDDATA%\Quake3`
* fs_basepath - the same directory as the ioquake3 executable.
* fs_steampath - Steam Quake 3 (if present).

ioq3-premake-msvc writes the compiled binaries to `build\vs201*\bin_*`. If you have the Steam version of Quake 3, this is not a problem - ioquake3 points fs_steampath to Steam and you can run the ioquake3 executable from anywhere. If you have the retail version of Quake 3, you have several options:

* Copy your Quake 3 baseq3 directory to `%APDDATA%\Quake3`
* Copy your Quake 3 baseq3 directory to `build\vs201*\bin_*`.
* Point fs_steampath at your Quake 3 directory. Open the ioquake3 project properties. Select "Debugging" and set "Command Arguments" to `+set fs_steampath "path"`, where path is the location of your Quake 3 install, e.g. `+set fs_steampath "D:\Games\Quake III Arena"`.

You should now be able to run ioquake3 with the Visual Studio debugger.

To debug game code, add `+set sv_pure 0 +set vm_cgame 0 +set vm_game 0 +set vm_ui 0` to the command arguments.

## BGFX renderer
An unofficial renderer using [bgfx](https://github.com/bkaradzic/bgfx) is available [here](https://github.com/jpcy/ioq3-renderer-bgfx). To generate a project file for it, clone to the same parent directory as [ioquake3](https://github.com/ioquake/ioq3) and [ioq3-premake-msvc](https://github.com/jpcy/ioq3-premake-msvc), then run premake again. Select the renderer in the game console with `cl_renderer bgfx` (requires a `vid_restart`).
