A Premake script for generating Visual Studio projects for [ioquake3](https://github.com/ioquake/ioq3).

## Instructions
1. Checkout [ioquake3](https://github.com/ioquake/ioq3) and this repository into the same parent directory.
2. Hold shift and right click on the `ioq3-premake-msvc` directory and select "Open command window here". Run the command `premake5 vs2013`.
3. Open `build\ioquake3.sln` in Visual Studio and compile.

The compiled binaries are written to `build\bin_*`. You can either manually copy them to your Quake 3 directory and run the ioquake3 executable, or read the section [Debugging ioquake3](#debugging-ioquake3) below.

## Options
Run the command `premake5 [options] vs2013`, where options are one or more of the following.

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
--rename-baseq3=NAME      | Rename the baseq3 project
--rename-missionpack=NAME | Rename the missionpack project
--standalone              | Remove the dependency on Q3A

For example, run `premake5 --disable-baseq3 --disable-missionpack vs2013` if you don't want the game code projects.

## Debugging ioquake3
ioquake3 requires the baseq3 directory containing pak*.pk3 files to be in one of its search paths to run. The search paths are:

* fs_homepath - %APDDATA%\Quake3
* fs_basepath - the same directory as the ioquake3 executable.
* fs_steampath - Steam Quake 3 (if present).

ioq3-premake-msvc writes the compiled binaries to `ioq3-premake-msvc\build\bin_*`. You can either copy your Quake 3 baseq3 directory there so it gets picked up by fs_basepath, or point fs_steampath at your Quake 3 directory. None of this is necessary if you have the Steam version of Quake 3, as fs_steampath is set automatically.

To point fs_steampath at your Quake 3 directory:

1. Go into the ioquake3 project properties.
2. Select "Debugging" and set "Command Arguments" to point fs_steampath to the location of your Quake 3 install, e.g. `+set fs_steampath "D:\Games\Quake III Arena"`.

You should now be able to run ioquake3 with the Visual Studio debugger (press F5).

To debug game code, add `+set sv_pure 0 +set vm_cgame 0 +set vm_game 0 +set vm_ui 0` to the command arguments.

## Extras
A work in progress renderer using bgfx to support multiple rendering APIs (OpenGL, D3D9, D3D11 etc.) is available [here](https://github.com/jpcy/ioq3-renderer-bgfx). Checkout to the same parent directory as [ioquake3](https://github.com/ioquake/ioq3) and [ioq3-premake-msvc](https://github.com/jpcy/ioq3-premake-msvc), then run premake again. Select the renderer in-game with `cl_renderer bgfx` and change the rendering backend with `r_backend` (both require a `vid_restart`).
