newoption
{
	trigger = "standalone",
	description = "Build the engine standalone"
}

-----------------------------------------------------------------------------

local IOQ3_PATH = path.join(path.getabsolute(".."), "ioq3")

if not os.isdir(IOQ3_PATH) then
	print("ioquake3 not found at " .. IOQ3_PATH)
	os.exit()
end

local IOQ3_CODE_PATH = path.join(IOQ3_PATH, "code")

if os.get() == "windows" then
	os.mkdir("build")
	os.mkdir("build/bin_x86")
	os.mkdir("build/bin_x64")
	os.mkdir("build/bin_debug_x86")
	os.mkdir("build/bin_debug_x64")
	
	-- Copy the SDL2 dlls to the build directories.
	os.copyfile("SDL2/x86/SDL2.dll", "build/bin_x86/SDL2.dll")
	os.copyfile("SDL2/x64/SDL2.dll", "build/bin_x64/SDL2.dll")
	os.copyfile("SDL2/x86/SDL2.dll", "build/bin_debug_x86/SDL2.dll")
	os.copyfile("SDL2/x64/SDL2.dll", "build/bin_debug_x64/SDL2.dll")
	
	-- The icon path is hardcoded in sys\win_resource.rc. Copy it to where it needs to be.
	os.copyfile(path.join(IOQ3_PATH, "misc/quake3.ico"), "quake3.ico")
end

-----------------------------------------------------------------------------

solution "ioquake3"
	language "C"
	location "build"
	startproject "ioquake3"
	platforms { "native", "x32", "x64" }
	configurations { "Debug", "Release" }
	defines { "_CRT_SECURE_NO_DEPRECATE" }
	
	configuration "x64"
		defines { "_WIN64", "__WIN64__" }
			
	configuration "Debug"
		optimize "Debug"
		defines { "_DEBUG" }
		flags "Symbols"
				
	configuration "Release"
		optimize "Full"
		defines "NDEBUG"
		
	configuration { "Debug", "not x64" }
		targetdir "build/bin_debug_x86"
		
	configuration { "Release", "not x64" }
		targetdir "build/bin_x86"
		
	configuration { "Debug", "x64" }
		targetdir "build/bin_debug_x64"
		
	configuration { "Release", "x64" }
		targetdir "build/bin_x64"
	
-----------------------------------------------------------------------------

group "engine"

project "ioquake3"
	kind "WindowedApp"
	
	configuration "x64"
		targetname "ioquake3.x86_64"
	configuration "not x64"
		targetname "ioquake3.x86"
	configuration {}
	
	defines
	{
		"_WIN32",
		"WIN32",
		"_WINSOCK_DEPRECATED_NO_WARNINGS",
		"BOTLIB",
		"USE_CURL",
		"USE_CURL_DLOPEN",
		"USE_OPENAL",
		"USE_OPENAL_DLOPEN",
		"USE_VOIP",
		"USE_RENDERER_DLOPEN",
		"USE_LOCAL_HEADERS"
	}
	
	filter "options:standalone"
		defines "STANDALONE"
	filter {}

	files
	{
		path.join(IOQ3_CODE_PATH, "asm/ftola.asm"),
		path.join(IOQ3_CODE_PATH, "asm/snapvector.asm"),
		path.join(IOQ3_CODE_PATH, "botlib/*.c"),
		path.join(IOQ3_CODE_PATH, "botlib/*.h"),
		path.join(IOQ3_CODE_PATH, "client/*.c"),
		path.join(IOQ3_CODE_PATH, "client/*.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/*.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/*.h"),
		path.join(IOQ3_CODE_PATH, "sdl/sdl_input.c"),
		path.join(IOQ3_CODE_PATH, "sdl/sdl_snd.c"),
		path.join(IOQ3_CODE_PATH, "server/*.c"),
		path.join(IOQ3_CODE_PATH, "server/*.h"),
		path.join(IOQ3_CODE_PATH, "sys/con_log.c"),
		path.join(IOQ3_CODE_PATH, "sys/con_passive.c"),
		path.join(IOQ3_CODE_PATH, "sys/sys_main.c"),
		path.join(IOQ3_CODE_PATH, "sys/sys_win32.c"),
		path.join(IOQ3_CODE_PATH, "sys/*.h"),
		path.join(IOQ3_CODE_PATH, "sys/*.rc")
	}
	
	configuration "x64"
		files { path.join(IOQ3_CODE_PATH, "asm/vm_x86_64.asm") }
	configuration {}
	
	excludes
	{
		path.join(IOQ3_CODE_PATH, "client/libmumblelink.*"),
		path.join(IOQ3_CODE_PATH, "qcommon/vm_none.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/vm_powerpc*.*"),
		path.join(IOQ3_CODE_PATH, "qcommon/vm_sparc.*"),
		path.join(IOQ3_CODE_PATH, "server/sv_rankings.c")
	}
	
	includedirs
	{
		path.join(IOQ3_CODE_PATH, "SDL2/include"),
		path.join(IOQ3_CODE_PATH, "libcurl"),
		path.join(IOQ3_CODE_PATH, "AL"),
		path.join(IOQ3_CODE_PATH, "libspeex/include"),
		path.join(IOQ3_CODE_PATH, "zlib"),
		path.join(IOQ3_CODE_PATH, "jpeg-8c"),
	}
	
	links
	{
		"user32",
		"advapi32",
		"winmm",
		"wsock32",
		"ws2_32",
		"OpenGL32",
		"psapi",
		"gdi32",

		-- Other projects
		"libspeex",
		"zlib"
	}
	
	configuration "not x64"
		links { "SDL2/x86/SDL2", "SDL2/x86/SDL2main" }
		
	configuration "x64"
		links { "SDL2/x64/SDL2", "SDL2/x64/SDL2main" }
		
	configuration {}
	
	-- for MSVC2012
	linkoptions "/SAFESEH:NO"
	
	configuration { "not x64", "**.asm" }
		buildmessage "Assembling..."
		buildcommands('ml /c /Zi /Fo"%{cfg.objdir}/%{file.basename}.asm.obj" "%{file.relpath}"')
		buildoutputs '%{cfg.objdir}/%{file.basename}.asm.obj'
		
	configuration { "x64", "**.asm" }
		buildmessage "Assembling..."
		buildcommands('ml64 /c /D idx64 /Zi /Fo"%{cfg.objdir}/%{file.basename}.asm.obj" "%{file.relpath}"')
		buildoutputs '%{cfg.objdir}/%{file.basename}.asm.obj'

-----------------------------------------------------------------------------

project "dedicated"
	kind "ConsoleApp"
	
	configuration "x64"
		targetname "ioq3ded.x86_64"
	configuration "not x64"
		targetname "ioq3ded.x86"
	configuration {}
	
	defines
	{
		"_WINSOCK_DEPRECATED_NO_WARNINGS",
		"DEDICATED",
		"BOTLIB",
		"USE_VOIP",
		"USE_LOCAL_HEADERS"
	}
	
	filter "options:standalone"
		defines "STANDALONE"
	filter {}

	files
	{
		path.join(IOQ3_CODE_PATH, "asm/ftola.asm"),
		path.join(IOQ3_CODE_PATH, "asm/snapvector.asm"),
		path.join(IOQ3_CODE_PATH, "botlib/*.c"),
		path.join(IOQ3_CODE_PATH, "botlib/*.h"),
		path.join(IOQ3_CODE_PATH, "null/null_client.c"),
		path.join(IOQ3_CODE_PATH, "null/null_input.c"),
		path.join(IOQ3_CODE_PATH, "null/null_snddma.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/*.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/*.h"),
		path.join(IOQ3_CODE_PATH, "server/*.c"),
		path.join(IOQ3_CODE_PATH, "server/*.h"),
		path.join(IOQ3_CODE_PATH, "sys/con_log.c"),
		path.join(IOQ3_CODE_PATH, "sys/con_win32.c"),
		path.join(IOQ3_CODE_PATH, "sys/sys_main.c"),
		path.join(IOQ3_CODE_PATH, "sys/sys_win32.c"),
		path.join(IOQ3_CODE_PATH, "sys/*.h"),
		path.join(IOQ3_CODE_PATH, "sys/*.rc")
	}
	
	configuration "x64"
		files { path.join(IOQ3_CODE_PATH, "asm/vm_x86_64.asm") }
	configuration {}
	
	excludes
	{
		path.join(IOQ3_CODE_PATH, "qcommon/vm_none.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/vm_powerpc*.*"),
		path.join(IOQ3_CODE_PATH, "qcommon/vm_sparc.*"),
		path.join(IOQ3_CODE_PATH, "server/sv_rankings.c")
	}
	
	includedirs { path.join(IOQ3_CODE_PATH, "zlib") }
	
	links
	{
		"winmm",
		"wsock32",
		"ws2_32",
		"psapi",
		
		-- Other projects
		"zlib"
	}
	
	-- for MSVC2012
	linkoptions "/SAFESEH:NO"
	
	configuration { "not x64", "**.asm" }
		buildmessage "Assembling..."
		buildcommands('ml /c /Zi /Fo"%{cfg.objdir}/%{file.basename}.asm.obj" "%{file.relpath}"')
		buildoutputs '%{cfg.objdir}/%{file.basename}.asm.obj'
		
	configuration { "x64", "**.asm" }
		buildmessage "Assembling..."
		buildcommands('ml64 /c /D idx64 /Zi /Fo"%{cfg.objdir}/%{file.basename}.asm.obj" "%{file.relpath}"')
		buildoutputs '%{cfg.objdir}/%{file.basename}.asm.obj'
		
-----------------------------------------------------------------------------

group "renderer"

project "renderer_opengl1"
	kind "SharedLib"
	
	configuration "x64"
		targetname "renderer_opengl1_x86_64"
	configuration "not x64"
		targetname "renderer_opengl1_x86"
	configuration {}

	defines
	{
		"_WIN32",
		"WIN32",
		"_WINDOWS",
		"USE_INTERNAL_JPEG",
		"USE_RENDERER_DLOPEN",
		"USE_LOCAL_HEADERS"
	}
	
	filter "options:standalone"
		defines "STANDALONE"
	filter {}
	
	files
	{
		path.join(IOQ3_CODE_PATH, "jpeg-8c/*.c"),
		path.join(IOQ3_CODE_PATH, "jpeg-8c/*.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_math.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/qcommon.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/qfiles.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/puff.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/puff.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/surfaceflags.h"),
		path.join(IOQ3_CODE_PATH, "renderergl1/*.c"),
		path.join(IOQ3_CODE_PATH, "renderergl1/*.h"),
		path.join(IOQ3_CODE_PATH, "renderercommon/*.c"),
		path.join(IOQ3_CODE_PATH, "renderercommon/*.h"),
		path.join(IOQ3_CODE_PATH, "sdl/sdl_gamma.c"),
		path.join(IOQ3_CODE_PATH, "sdl/sdl_glimp.c")
	}
	
	includedirs
	{
		path.join(IOQ3_CODE_PATH, "SDL2/include"),
		path.join(IOQ3_CODE_PATH, "libcurl"),
		path.join(IOQ3_CODE_PATH, "AL"),
		path.join(IOQ3_CODE_PATH, "libspeex/include"),
		path.join(IOQ3_CODE_PATH, "zlib"),
		path.join(IOQ3_CODE_PATH, "jpeg-8c")
	}
	
	links
	{
		"user32",
		"advapi32",
		"winmm",
		"wsock32",
		"ws2_32",
		"OpenGL32",
		"psapi",
		
		-- Other projects
		"zlib"
	}
	
	configuration "not x64"
		links { "SDL2/x86/SDL2" }
		
	configuration "x64"
		buildoptions { "/wd\"4267\""} -- Silence size_t type conversion warnings
		links { "SDL2/x64/SDL2" }

-----------------------------------------------------------------------------

project "renderer_opengl2"
	kind "SharedLib"
	
	configuration "x64"
		targetname "renderer_opengl2_x86_64"
	configuration "not x64"
		targetname "renderer_opengl2_x86"
	configuration {}

	defines
	{
		"_WIN32",
		"WIN32",
		"USE_INTERNAL_JPEG",
		"USE_RENDERER_DLOPEN",
		"USE_LOCAL_HEADERS"
	}
	
	filter "options:standalone"
		defines "STANDALONE"
	filter {}

	files
	{
		-- Name the stringified GLSL files explicitly (without * wildcard) so they're added to the project even when they don't exist yet
		"build/dynamic/renderergl2/bokeh_fp.c",
		"build/dynamic/renderergl2/bokeh_vp.c",
		"build/dynamic/renderergl2/calclevels4x_fp.c",
		"build/dynamic/renderergl2/calclevels4x_vp.c",
		"build/dynamic/renderergl2/depthblur_fp.c",
		"build/dynamic/renderergl2/depthblur_vp.c",
		"build/dynamic/renderergl2/dlight_fp.c",
		"build/dynamic/renderergl2/dlight_vp.c",
		"build/dynamic/renderergl2/down4x_fp.c",
		"build/dynamic/renderergl2/down4x_vp.c",
		"build/dynamic/renderergl2/fogpass_fp.c",
		"build/dynamic/renderergl2/fogpass_vp.c",
		"build/dynamic/renderergl2/generic_fp.c",
		"build/dynamic/renderergl2/generic_vp.c",
		"build/dynamic/renderergl2/lightall_fp.c",
		"build/dynamic/renderergl2/lightall_vp.c",
		"build/dynamic/renderergl2/pshadow_fp.c",
		"build/dynamic/renderergl2/pshadow_vp.c",
		"build/dynamic/renderergl2/shadowfill_fp.c",
		"build/dynamic/renderergl2/shadowfill_vp.c",
		"build/dynamic/renderergl2/shadowmask_fp.c",
		"build/dynamic/renderergl2/shadowmask_vp.c",
		"build/dynamic/renderergl2/ssao_fp.c",
		"build/dynamic/renderergl2/ssao_vp.c",
		"build/dynamic/renderergl2/texturecolor_fp.c",
		"build/dynamic/renderergl2/texturecolor_vp.c",
		"build/dynamic/renderergl2/tonemap_fp.c",
		"build/dynamic/renderergl2/tonemap_vp.c",
		path.join(IOQ3_CODE_PATH, "jpeg-8c/*.c"),
		path.join(IOQ3_CODE_PATH, "jpeg-8c/*.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_math.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/qcommon.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/qfiles.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/puff.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/puff.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/surfaceflags.h"),
		path.join(IOQ3_CODE_PATH, "renderergl2/*.c"),
		path.join(IOQ3_CODE_PATH, "renderergl2/*.h"),
		path.join(IOQ3_CODE_PATH, "renderergl2/glsl/*.glsl"),
		path.join(IOQ3_CODE_PATH, "renderercommon/*.c"),
		path.join(IOQ3_CODE_PATH, "renderercommon/*.h"),
		path.join(IOQ3_CODE_PATH, "sdl/sdl_gamma.c"),
		path.join(IOQ3_CODE_PATH, "sdl/sdl_glimp.c")
	}
	
	-- The stringified GLSL files cause virtual paths to be a little too deeply nested
	vpaths
	{
		["dynamic"] = "build/dynamic/renderergl2/*.c",
		["*"] = IOQ3_CODE_PATH
	}
	
	includedirs
	{
		path.join(IOQ3_CODE_PATH, "SDL2/include"),
		path.join(IOQ3_CODE_PATH, "libcurl"),
		path.join(IOQ3_CODE_PATH, "AL"),
		path.join(IOQ3_CODE_PATH, "libspeex/include"),
		path.join(IOQ3_CODE_PATH, "zlib"),
		path.join(IOQ3_CODE_PATH, "jpeg-8c")
	}
	
	links
	{
		"user32",
		"advapi32",
		"winmm",
		"wsock32",
		"ws2_32",
		"OpenGL32",
		"psapi",
		
		-- Other projects
		"zlib"
	}
	
	configuration "not x64"
		links { "SDL2/x86/SDL2" }
		
	configuration "x64"
		buildoptions { "/wd\"4267\""} -- Silence size_t type conversion warnings
		links { "SDL2/x64/SDL2" }
		
	configuration {}
	
	configuration "**.glsl"
		buildmessage "Stringifying %{file.basename}.glsl"
		buildcommands("cscript.exe \"" .. path.join(IOQ3_PATH, "misc/msvc/glsl_stringify.vbs") .. "\" //Nologo \"%{file.relpath}\" \"dynamic\\renderergl2\\%{file.basename}.c\"")
		buildoutputs "build\\dynamic\\renderergl2\\%{file.basename}.c"

-----------------------------------------------------------------------------

function setGameTarget(dir, name)
	configuration { "Debug", "not x64" }
		targetdir("build/bin_debug_x86/" .. dir)
		targetname(name .. "x86")
	configuration { "Release", "not x64" }
		targetdir("build/bin_x86/" .. dir)
		targetname(name .. "x86")
	configuration { "Debug", "x64" }
		targetdir("build/bin_debug_x64/" .. dir)
		targetname(name .. "x86_64")
	configuration { "Release", "x64" }
		targetdir("build/bin_x64/" .. dir)
		targetname(name .. "x86_64")
	configuration {}
end

group "game_dll"

-----------------------------------------------------------------------------

project "baseq3_cgame_dll"
	kind "SharedLib"
	setGameTarget("baseq3", "cgame")
	
	filter "options:standalone"
		defines "STANDALONE"
	filter {}

	files
	{
		path.join(IOQ3_CODE_PATH, "cgame/*.c"),
		path.join(IOQ3_CODE_PATH, "cgame/*.h"),
		path.join(IOQ3_CODE_PATH, "game/bg_*.c"),
		path.join(IOQ3_CODE_PATH, "game/bg_*.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_math.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/surfaceflags.h")
	}
	
	excludes
	{
		path.join(IOQ3_CODE_PATH, "cgame/cg_newdraw.c"),
		path.join(IOQ3_CODE_PATH, "game/bg_lib.*")
	}
	
	links "winmm"
	
-----------------------------------------------------------------------------

project "baseq3_game_dll"
	kind "SharedLib"
	setGameTarget("baseq3", "qagame")
	
	filter "options:standalone"
		defines "STANDALONE"
	filter {}
	
	files
	{
		path.join(IOQ3_CODE_PATH, "game/*.c"),
		path.join(IOQ3_CODE_PATH, "game/*.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_math.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/surfaceflags.h")
	}
	
	excludes
	{
		path.join(IOQ3_CODE_PATH, "game/bg_lib.*"),
		path.join(IOQ3_CODE_PATH, "game/g_rankings.c")
	}
	
	links "winmm"

-----------------------------------------------------------------------------

project "baseq3_ui_dll"
	kind "SharedLib"
	setGameTarget("baseq3", "ui")
	
	filter "options:standalone"
		defines "STANDALONE"
	filter {}
	
	files
	{
		path.join(IOQ3_CODE_PATH, "game/bg_misc.c"),
		path.join(IOQ3_CODE_PATH, "q3_ui/*.c"),
		path.join(IOQ3_CODE_PATH, "q3_ui/*.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_math.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.h"),
		path.join(IOQ3_CODE_PATH, "ui/ui_syscalls.c")
	}
	
	excludes
	{
		path.join(IOQ3_CODE_PATH, "q3_ui/ui_loadconfig.c"),
		path.join(IOQ3_CODE_PATH, "q3_ui/ui_login.c"),
		path.join(IOQ3_CODE_PATH, "q3_ui/ui_rankings.c"),
		path.join(IOQ3_CODE_PATH, "q3_ui/ui_rankstatus.c"),
		path.join(IOQ3_CODE_PATH, "q3_ui/ui_saveconfig.c"),
		path.join(IOQ3_CODE_PATH, "q3_ui/ui_signup.c"),
		path.join(IOQ3_CODE_PATH, "q3_ui/ui_specifyleague.c")
	}
	
	links "winmm"

-----------------------------------------------------------------------------

project "missionpack_cgame_dll"
	kind "SharedLib"
	setGameTarget("missionpack", "cgame")
	
	defines
	{
		"MISSIONPACK"
	}
	
	filter "options:standalone"
		defines "STANDALONE"
	filter {}

	files
	{
		path.join(IOQ3_CODE_PATH, "cgame/*.c"),
		path.join(IOQ3_CODE_PATH, "cgame/*.h"),
		path.join(IOQ3_CODE_PATH, "game/bg_*.c"),
		path.join(IOQ3_CODE_PATH, "game/bg_*.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_math.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/surfaceflags.h"),
		path.join(IOQ3_CODE_PATH, "ui/ui_shared.*")
	}
	
	excludes
	{
		path.join(IOQ3_CODE_PATH, "game/bg_lib.*")
	}
	
	links "winmm"

-----------------------------------------------------------------------------

project "missionpack_game_dll"
	kind "SharedLib"
	setGameTarget("missionpack", "qagame")
	
	defines
	{
		"MISSIONPACK"
	}
	
	filter "options:standalone"
		defines "STANDALONE"
	filter {}

	files
	{
		path.join(IOQ3_CODE_PATH, "game/*.c"),
		path.join(IOQ3_CODE_PATH, "game/*.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_math.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/surfaceflags.h")
	}
	
	excludes
	{
		path.join(IOQ3_CODE_PATH, "game/bg_lib.*"),
		path.join(IOQ3_CODE_PATH, "game/g_rankings.c")
	}
	
	links "winmm"

-----------------------------------------------------------------------------

project "missionpack_ui_dll"
	kind "SharedLib"
	setGameTarget("missionpack", "ui")
	
	filter "options:standalone"
		defines "STANDALONE"
	filter {}
	
	files
	{
		path.join(IOQ3_CODE_PATH, "game/bg_misc.c"),
		path.join(IOQ3_CODE_PATH, "game/bg_public.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_math.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.h"),
		path.join(IOQ3_CODE_PATH, "ui/*.c"),
		path.join(IOQ3_CODE_PATH, "ui/*.h")
	}
	
	links { "odbc32", "odbccp32" }

-----------------------------------------------------------------------------

group "game_qvm"

function setupQvmBuild(mod, qvm, syscalls, defines)
	kind "StaticLib"
	links { "lcc", "q3asm", "q3cpp", "q3rcc" } -- build dependencies
	
	configuration "**.c"
		buildmessage "lcc %{file.name}"
		buildcommands("\"%{cfg.targetdir}\\lcc.exe\" " .. defines .. " -S -Wf-target=bytecode -Wf-g -Wo-lccdir=\"%{cfg.targetdir}\" -o \"%{cfg.objdir}\\%{file.basename}.asm\" \"%{file.relpath}\"")
		buildoutputs "%{cfg.objdir}\\%{file.basename}.asm"
	configuration {}
	
	postbuildcommands
	{
		"cd %{cfg.objdir}",
		"dir /b *.asm > files.q3asm",
		"\"$(TargetDir)/q3asm.exe\" -o \"$(TargetDir)/" .. mod .. "/" .. qvm .. "\" -f files.q3asm " .. path.join(IOQ3_CODE_PATH, syscalls)
	}
end

-----------------------------------------------------------------------------

project "baseq3_cgame_qvm"
	setupQvmBuild("baseq3", "cgame", "cgame/cg_syscalls.asm", "-DQ3_VM")
	
	files
	{
		path.join(IOQ3_CODE_PATH, "cgame/*.c"),
		path.join(IOQ3_CODE_PATH, "cgame/*.h"),
		path.join(IOQ3_CODE_PATH, "game/bg_*.c"),
		path.join(IOQ3_CODE_PATH, "game/bg_*.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_math.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/surfaceflags.h")
	}
	
	excludes
	{
		path.join(IOQ3_CODE_PATH, "cgame/cg_newdraw.c"),
		path.join(IOQ3_CODE_PATH, "cgame/cg_syscalls.c")
	}

-----------------------------------------------------------------------------

project "baseq3_game_qvm"
	setupQvmBuild("baseq3", "qagame", "game/g_syscalls.asm", "-DQ3_VM")
	
	files
	{
		path.join(IOQ3_CODE_PATH, "game/*.c"),
		path.join(IOQ3_CODE_PATH, "game/*.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_math.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/surfaceflags.h")
	}
	
	excludes
	{
		path.join(IOQ3_CODE_PATH, "game/g_rankings.c"),
		path.join(IOQ3_CODE_PATH, "game/g_syscalls.c")
	}
	
-----------------------------------------------------------------------------

project "baseq3_ui_qvm"
	setupQvmBuild("baseq3", "ui", "ui/ui_syscalls.asm", "-DQ3_VM")
	
	files
	{
		path.join(IOQ3_CODE_PATH, "game/bg_misc.c"),
		path.join(IOQ3_CODE_PATH, "game/bg_lib.*"),
		path.join(IOQ3_CODE_PATH, "q3_ui/*.c"),
		path.join(IOQ3_CODE_PATH, "q3_ui/*.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_math.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.h")
	}
	
	excludes
	{
		path.join(IOQ3_CODE_PATH, "q3_ui/ui_loadconfig.c"),
		path.join(IOQ3_CODE_PATH, "q3_ui/ui_login.c"),
		path.join(IOQ3_CODE_PATH, "q3_ui/ui_rankings.c"),
		path.join(IOQ3_CODE_PATH, "q3_ui/ui_rankstatus.c"),
		path.join(IOQ3_CODE_PATH, "q3_ui/ui_saveconfig.c"),
		path.join(IOQ3_CODE_PATH, "q3_ui/ui_signup.c"),
		path.join(IOQ3_CODE_PATH, "q3_ui/ui_specifyleague.c")
	}

-----------------------------------------------------------------------------

project "missionpack_cgame_qvm"
	setupQvmBuild("missionpack", "cgame", "cgame/cg_syscalls.asm", "-DQ3_VM -DMISSIONPACK")

	files
	{
		path.join(IOQ3_CODE_PATH, "cgame/*.c"),
		path.join(IOQ3_CODE_PATH, "cgame/*.h"),
		path.join(IOQ3_CODE_PATH, "game/bg_*.c"),
		path.join(IOQ3_CODE_PATH, "game/bg_*.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_math.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/surfaceflags.h"),
		path.join(IOQ3_CODE_PATH, "ui/ui_shared.*")
	}
	
	excludes
	{
		path.join(IOQ3_CODE_PATH, "cgame/cg_syscalls.c")
	}
	
-----------------------------------------------------------------------------

project "missionpack_game_qvm"
	setupQvmBuild("missionpack", "qagame", "game/g_syscalls.asm", "-DQ3_VM -DMISSIONPACK")

	files
	{
		path.join(IOQ3_CODE_PATH, "game/*.c"),
		path.join(IOQ3_CODE_PATH, "game/*.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_math.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/surfaceflags.h")
	}
	
	excludes
	{
		path.join(IOQ3_CODE_PATH, "game/g_rankings.c"),
		path.join(IOQ3_CODE_PATH, "game/g_syscalls.c")
	}

-----------------------------------------------------------------------------

project "missionpack_ui_qvm"
	setupQvmBuild("missionpack", "ui", "ui/ui_syscalls.asm", "-DQ3_VM -DMISSIONPACK")
	
	files
	{
		path.join(IOQ3_CODE_PATH, "game/bg_lib.*"),
		path.join(IOQ3_CODE_PATH, "game/bg_misc.c"),
		path.join(IOQ3_CODE_PATH, "game/bg_public.h"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_math.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.c"),
		path.join(IOQ3_CODE_PATH, "qcommon/q_shared.h"),
		path.join(IOQ3_CODE_PATH, "ui/*.c"),
		path.join(IOQ3_CODE_PATH, "ui/*.h")
	}
	
	excludes
	{
		path.join(IOQ3_CODE_PATH, "ui/ui_syscalls.c")
	}
	
-----------------------------------------------------------------------------

group "lib"

project "libspeex"
	kind "StaticLib"
	defines { "HAVE_CONFIG_H", "WIN32" } -- alloca is undefined if WIN32 is omitted. x64 needs it too.
	files { path.join(IOQ3_CODE_PATH, "libspeex/*.c"), path.join(IOQ3_CODE_PATH, "libspeex/*.h"), path.join(IOQ3_CODE_PATH, "libspeex/include/speex/*.h") }
	excludes { path.join(IOQ3_CODE_PATH, "libspeex/test*.c") }
	includedirs { path.join(IOQ3_CODE_PATH, "libspeex/include") }
	buildoptions { "/wd\"4018\"", "/wd\"4047\"", "/wd\"4244\"", "/wd\"4267\"", "/wd\"4305\"" } -- Silence some warnings
		
-----------------------------------------------------------------------------

project "zlib"
	kind "StaticLib"
	files { path.join(IOQ3_CODE_PATH, "zlib/*.c"), path.join(IOQ3_CODE_PATH, "zlib/*.h") }

-----------------------------------------------------------------------------

group "tool"

project "lburg"
	kind "ConsoleApp"
	defines { "WIN32" }
	files { path.join(IOQ3_CODE_PATH, "tools/lcc/lburg/*.c"), path.join(IOQ3_CODE_PATH, "tools/lcc/lburg/*.h") }

project "lcc"
	kind "ConsoleApp"
	defines { "WIN32" }
	files { path.join(IOQ3_CODE_PATH, "tools/lcc/etc/*.c") }
	buildoptions
	{
		"/wd\"4273\"", -- "inconsistent dll linkage" getpid
		"/wd\"4996\"" -- "The POSIX name for this item is deprecated. Instead, use the ISO C++ conformant name"
	}

project "q3asm"
	kind "ConsoleApp"
	defines { "WIN32" }
	files { path.join(IOQ3_CODE_PATH, "tools/asm/*.c"), path.join(IOQ3_CODE_PATH, "tools/asm/*.h") }
	buildoptions { "/wd\"4273\""} -- "inconsistent dll linkage" strupr
	
project "q3cpp"
	kind "ConsoleApp"
	defines { "WIN32" }
	files { path.join(IOQ3_CODE_PATH, "tools/lcc/cpp/*.c"), path.join(IOQ3_CODE_PATH, "tools/lcc/cpp/*.h") }
	buildoptions
	{
		"/wd\"4018\"", -- "signed/unsigned mismatch"
		"/wd\"4996\"" -- "The POSIX name for this item is deprecated. Instead, use the ISO C++ conformant name"
	}

project "q3rcc"
	kind "ConsoleApp"
	defines { "WIN32" }
	files
	{
		path.join(IOQ3_CODE_PATH, "tools/lcc/src/*.c"),
		path.join(IOQ3_CODE_PATH, "tools/lcc/src/*.h"),
		path.join(IOQ3_CODE_PATH, "tools/lcc/src/dagcheck.md"),
		"build/dynamic/dagcheck.c"
	}
	
	vpaths
	{
		["dynamic"] = "build/dynamic/*.c",
		["*"] = path.join(IOQ3_CODE_PATH, "tools/lcc/src")
	}
	
	includedirs { path.join(IOQ3_CODE_PATH, "tools/lcc/src") } -- for dagcheck.c
	links { "lburg" } -- build dependency
	
	buildoptions
	{
		"/wd\"4018\"", -- "signed/unsigned mismatch"
		"/wd\"4244\"" -- "conversion from 'x' to 'y', possible loss of data"
	}

	configuration "**.md"
		buildmessage "lburg %{file.basename}"
		buildcommands("\"" .. path.join("%{cfg.targetdir}", "lburg.exe") .. "\" \"%{file.relpath}\" > \"dynamic\\%{file.basename}.c\"")
		buildoutputs "build\\dynamic\\%{file.basename}.c"
