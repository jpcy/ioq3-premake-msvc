A Premake script for generating Visual Studio projects for [ioquake3](https://github.com/ioquake/ioq3).

## Instructions
1. Checkout [ioquake3](https://github.com/ioquake/ioq3) and this repository to the same parent directory.
2. Run `vs2013.bat` or `vs2015.bat`.
3. Open `build\ioquake3.sln` in Visual Studio and compile.

The compiled binaries are written to `build\bin_*`. You can either manually copy them to your Quake 3 directory and run the ioquake3 executable, or read the section [Debugging ioquake3](#debugging-ioquake3) below.

## Options
As an alternative to `vs2013.bat` and `vs2015.bat`, invoke premake directly with `premake5 [options] [action]`, where [options] are one or more of the following, and [action] is either vs2013 or vs2015.

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

For example, run `premake5 --disable-baseq3 --disable-missionpack vs2015` if you don't want the game code projects.

## Debugging ioquake3
ioquake3 requires the baseq3 directory containing pak*.pk3 files to be in one of its search paths to run. The search paths are:

* fs_homepath - `%APDDATA%\Quake3`
* fs_basepath - the same directory as the ioquake3 executable.
* fs_steampath - Steam Quake 3 (if present).

ioq3-premake-msvc writes the compiled binaries to `build\bin_*`. If you have the Steam version of Quake 3, this is not a problem - ioquake3 points fs_steampath to Steam and you can run the ioquake3 executable from anywhere. If you have the retail version of Quake 3, you have several options:

* Copy your Quake 3 baseq3 directory to `%APDDATA%\Quake3`
* Copy your Quake 3 baseq3 directory to `build\bin_*`.
* Point fs_steampath at your Quake 3 directory. Open the ioquake3 project properties. Select "Debugging" and set "Command Arguments" to `+set fs_steampath "path"`, where path is the location of your Quake 3 install, e.g. `+set fs_steampath "D:\Games\Quake III Arena"`.

You should now be able to run ioquake3 with the Visual Studio debugger.

To debug game code, add `+set sv_pure 0 +set vm_cgame 0 +set vm_game 0 +set vm_ui 0` to the command arguments.

## Extras
A work in progress renderer using [bgfx](https://github.com/bkaradzic/bgfx) to support multiple rendering APIs (OpenGL, D3D9, D3D11 etc.) is available [here](https://github.com/jpcy/ioq3-renderer-bgfx). Checkout to the same parent directory as [ioquake3](https://github.com/ioquake/ioq3) and [ioq3-premake-msvc](https://github.com/jpcy/ioq3-premake-msvc), then run premake again. Select the renderer in-game with `cl_renderer bgfx` and change the rendering backend with `r_backend` (both require a `vid_restart`).
