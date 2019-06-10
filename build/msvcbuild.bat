@rem Script to build bestdesk, bestwin with MSVC.
@rem
@rem Either open a "Visual Studio .NET Command Prompt"
@rem (Note that the Express Edition does not contain an x64 compiler)
@rem -or-
@rem Open a "Windows SDK Command Shell" and set the compiler environment:
@rem     setenv /release /x86
@rem   -or-
@rem     setenv /release /x64
@rem
@rem Then cd to this directory and run this script.

@if not defined INCLUDE goto :FAIL

@setlocal
@set LJCOMPILE=cl /nologo /c /O2 /W3 /D_CRT_SECURE_NO_DEPRECATE
@set LJLINK=link /nologo
@set LJMT=mt /nologo
@set LJLIB=lib /nologo /nodefaultlib

@set LUAC=luajit -b
@set LJDLLNAME=lua51.dll
@set LJLIBNAME=bin/lua51.lib

%LUAC% blend2d/blcontext.lua blcontext.obj
%LUAC% blend2d/blend2d_ffi.lua blend2d_ffi.obj
%LUAC% blend2d/blend2d.lua blend2d.obj

@set BLEND2DLIB=blcontext.obj blend2d_ffi.obj blend2d.obj


@rem The best core library
%LUAC% ../best/BLDIBSection.lua BLDIBSection.obj
%LUAC% ../best/blerror.lua blerror.obj
%LUAC% ../best/collections.lua collections.obj
%LUAC% ../best/coloring.lua coloring.obj
%LUAC% ../best/DrawingContext.lua DrawingContext.obj
%LUAC% ../best/enum.lua enum.obj
%LUAC% ../best/filesystem.lua filesystem.obj
%LUAC% ../best/FontMonger.lua FontMonger.obj
%LUAC% ../best/functor.lua functor.obj
%LUAC% ../best/Gradient.lua Gradient.obj
%LUAC% ../best/maths.lua maths.obj
%LUAC% ../best/scheduler.lua scheduler.obj
%LUAC% ../best/spairs.lua spairs.obj
%LUAC% ../best/unicode_util.lua unicode_util.obj
%LUAC% ../best/vkeys.lua vkeys.obj
%LUAC% ../best/win32.lua win32.obj
@set BESTLIB=BLDIBSection.obj blerror.obj collections.obj coloring.obj ContextRecorder.obj DrawingContext.obj  enum.obj filesystem.obj FontMonger.obj functor.obj Gradient.obj maths.obj scheduler.obj spairs.obj unicode_util.obj vkeys.obj win32.obj

@rem The BEST GUI Library
%LUAC% ../best/BView.lua BView.obj
%LUAC% ../best/CheckerGraphic.lua CheckerGraphic.obj
%LUAC% ../best/CloseBox.lua CloseBox.obj
%LUAC% ../best/ContextRecorder.lua ContextRecorder.obj
%LUAC% ../best/Drawable.lua Drawable.obj
%LUAC% ../best/GImage.lua GImage.obj
%LUAC% ../best/Graphic.lua Graphic.obj
%LUAC% ../best/GraphicGroup.lua GraphicGroup.obj
%LUAC% ../best/GSVGPath.lua GSVGPath.obj
%LUAC% ../best/guistyle.lua guistyle.obj
%LUAC% ../best/MotionConstraint.lua MotionConstraint.obj
%LUAC% ../best/slider.lua slider.obj
%LUAC% ../best/SliderThumb.lua SliderThumb.obj
%LUAC% ../best/TitleBar.lua TitleBar.obj
%LUAC% ../best/Window.lua Window.obj


@set BESTGUILIB=BView.obj CheckerGraphic.obj CloseBox.obj ContextRecorder.obj Drawable.obj  GImage.obj Graphic.obj GraphicGroup.obj GSVGPath.obj guistyle.obj MotionConstraint.obj slider.obj SliderThumb.obj TitleBar.obj Window.obj


@rem DeskTopper Specifics
%LUAC% ../best/DeskTopper.lua DeskTopper.obj

@set DESKTOPPERLIB=DeskTopper.obj


@rem WinMan Specifics
%LUAC% ../best/WinMan.lua WinMan.obj

@set WINMANLIB=WinMan.obj


%LJCOMPILE% bestdesk.c
@if errorlevel 1 goto :BAD

%LJLINK% /out:bestdesk.exe %LJLIBNAME% bestdesk.obj %CLIBS% %BESTLIB% %BESTGUILIB% %BLEND2DLIB% %DESKTOPPERLIB%
@if errorlevel 1 goto :BAD
if exist bestdesk.exe.manifest^
  %LJMT% -manifest bestdesk.exe.manifest -outputresource:bestdesk.exe



del *.obj *.manifest
@echo.
@echo === Successfully built bestdesk for Windows/%LJARCH% ===
move bestdesk.exe bin 

goto :END
:BAD
@echo.
@echo *******************************************************
@echo *** Build FAILED -- Please check the error messages ***
@echo *******************************************************
@goto :END
:FAIL
@echo You must open a "Visual Studio .NET Command Prompt" to run this script
:END
