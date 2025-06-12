@ECHO OFF
setlocal EnableDelayedExpansion

set project_path=argon2
set install_path=C:\Raytec-Dev-3

REM **************************************************************************
REM **************************************************************************

set do_debug=0
set do_clean=0
set do_pause=1
set use_msvc=0

for %%x in (%*) do (
	IF "%%x"=="silent" ( set do_pause=0)
	IF "%%x"=="clean"  ( set do_clean=1)
	IF "%%x"=="debug"  ( set do_debug=1)
	IF "%%x"=="msvc" ( set use_msvc=1 )
)

for /d %%A in ("C:\Program Files (x86)\Windows Kits\10\bin\10.0."*) do (
	SET WINKITVER=%%~nxA
)
echo Windows Kit detected: %WINKITVER%

for /d %%A in ("C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\14."*) do (
	SET MSVCVER=%%~nxA
)
echo MSVC Version detected: %MSVCVER%

IF %use_msvc%==1 (
	set "INCLUDE=C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\%MSVCVER%\include;C:\Program Files (x86)\Windows Kits\10\include\%WINKITVER%\ucrt;C:\Program Files (x86)\Windows Kits\10\include\%WINKITVER%\shared;C:\Program Files (x86)\Windows Kits\10\include\%WINKITVER%\um;C:\Program Files (x86)\Windows Kits\10\include\%WINKITVER%\winrt;C:\Program Files (x86)\Windows Kits\10\include\%WINKITVER%\cppwinrt;"
	set "LIB=C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\%MSVCVER%\lib\x64;C:\Program Files (x86)\Windows Kits\10\lib\%WINKITVER%\ucrt\x64;C:\Program Files (x86)\Windows Kits\10\lib\%WINKITVER%\um\x64;"
	set "LIBPATH=C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\%MSVCVER%\lib\x64;C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\%MSVCVER%\lib\x86\store\references;C:\Program Files (x86)\Windows Kits\10\UnionMetadata\%WINKITVER%;C:\Program Files (x86)\Windows Kits\10\References\%WINKITVER%;"

	set "ADD_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\%MSVCVER%\bin\HostX64\x64;C:\Program Files (x86)\Windows Kits\10\bin\%WINKITVER%\x64;C:\Program Files (x86)\Windows Kits\10\bin\x64;C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\bin;C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\Common7\Tools\;C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\%MSVCVER%\bin\HostX64\x64;C:\Qt\Qt5.12.12\Tools\msvc2017_64\bin;C:\Qt\Qt5.12.12\5.12.12\msvc2017_64\bin;C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\%MSVCVER%\bin\Hostx64\x64;C:\Qt\Qt5.12.12\Tools\QtCreator\bin\jom;"

	set cmake_variables_qt="-DCMAKE_CXX_COMPILER=C:/Program Files (x86)/Microsoft Visual Studio/2017/BuildTools/VC/Tools/MSVC/14.16.27023/bin/HostX64/x64/cl.exe"
	call set cmake_variables_qt=%%cmake_variables_qt%% "-DCMAKE_PREFIX_PATH=C:/Qt/Qt5.12.12/5.12.12/msvc2017_64"
	call set cmake_variables_qt=%%cmake_variables_qt%% "-DCMAKE_PROJECT_INCLUDE_BEFORE=C:/Qt/Qt5.12.12/Tools/QtCreator/share/qtcreator/package-manager/auto-setup.cmake"
	call set cmake_variables_qt=%%cmake_variables_qt%% "-DQT_CREATOR_SKIP_PACKAGE_MANAGER_SETUP=OFF"
) ELSE (
	set "ADD_PATH=C:\Qt\Qt5.5.1\Tools\mingw492_32\bin;C:\Qt\Qt5.12.12\Tools\QtCreator\bin;C:\Qt\Qt5.12.12\Tools\QtCreator\bin\jom;"
	set "QTDIR=C:\Qt\Qt5.5.1\5.5\mingw492_32"

	set cmake_variables_qt="-DCMAKE_CXX_COMPILER=C:\Qt\Qt5.5.1\Tools\mingw492_32\bin\g++.exe"
	call set cmake_variables_qt=%%cmake_variables_qt%% "-DCMAKE_C_COMPILER=C:/Qt/Qt5.5.1/Tools/mingw492_32/bin/gcc.exe"
	call set cmake_variables_qt=%%cmake_variables_qt%% "-DCMAKE_PROJECT_INCLUDE_BEFORE=C:/Qt/Qt5.12.12/Tools/QtCreator/share/qtcreator/package-manager/auto-setup.cmake"
	call set cmake_variables_qt=%%cmake_variables_qt%% "-DCMAKE_GNUtoMS=OFF"
	call set cmake_variables_qt=%%cmake_variables_qt%% "-DCMAKE_PREFIX_PATH=C:/Qt/Qt5.5.1/5.5/mingw492_32"
	call set cmake_variables_qt=%%cmake_variables_qt%% "-DQT_CREATOR_SKIP_PACKAGE_MANAGER_SETUP=OFF"
	call set cmake_variables_qt=%%cmake_variables_qt%% "-DQT_QMAKE_EXECUTABLE=C:/Qt/Qt5.5.1/5.5/mingw492_32/bin/qmake.exe"
)

set PATH=%PATH%%ADD_PATH%

REM **************************************************************************
REM **************************************************************************

IF "%do_debug%"=="0" (
	IF %use_msvc%==1 (
		set make_path=build-%project_path%-Desktop_Qt_5_12_12_MSVC2017_64bit-Release
	) ELSE (
		set make_path=build-%project_path%-Desktop_Qt_5_5_1_MinGW_32bit-Release
	)

	set make_tag=Release
) ELSE (
	IF %use_msvc%==1 (
		set make_path=build-%project_path%-Desktop_Qt_5_12_12_MSVC2017_64bit-Debug
	) ELSE (
		set make_path=build-%project_path%-Desktop_Qt_5_5_1_MinGW_32bit-Debug
	)

	set make_tag=Debug
)

REM **************************************************************************
REM **************************************************************************

cd ..\
IF "%do_clean%"=="1" ( 
	echo **************************************************************************
	echo *          %project_path% : CLEAR BUILD DIR AND INSTALLATION FILES
	echo **************************************************************************

	rmdir /s /q %install_path%"\"%project_path%"\"%make_tag%

	rmdir /s /q %make_path% 
)

IF not exist %make_path%"\"  mkdir %make_path%  
cd %make_path%

echo **************************************************************************
IF "%do_clean%"=="1" ( echo *         %project_path% : MAKE + CLEAN + BUILD 
)ELSE								 ( echo *         %project_path% : MAKE + BUILD 
)
echo **************************************************************************

echo %cmake_variables_qt%

cmake -S ..\%project_path% -B ..\%make_path% "-GNMake Makefiles JOM" "-DCMAKE_BUILD_TYPE=%make_tag%" %cmake_variables_qt%

IF "%do_clean%"=="1" (
	cmake --build ..\%make_path% --target clean	
)
	
cmake --build ..\%make_path% --target all install

cd ..\
cd %project_path%
IF "%do_pause%"=="1" ( pause )

endlocal