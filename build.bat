@ECHO OFF

set project_path=argon2
set install_path=C:\Raytec-Dev-3

REM **************************************************************************
REM **************************************************************************

set do_debug=0
set do_clean=0
set do_pause=1

for %%x in (%*) do (
	IF "%%x"=="silent" ( set do_pause=0)
	IF "%%x"=="clean"  ( set do_clean=1)
	IF "%%x"=="debug"  ( set do_debug=1)
)

REM **************************************************************************
REM **************************************************************************

IF "%do_debug%"=="0" (
	set make_path=build-%project_path%-Desktop_Qt_5_5_1_MinGW_32bit-Release
	set make_tag=Release
	set make_arguments=
) ELSE (
	set make_path=build-%project_path%-Desktop_Qt_5_5_1_MinGW_32bit-Debug
	set make_tag=Debug
	set make_arguments="CONFIG+=debug"
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
cd %project_path% 


echo **************************************************************************
IF "%do_clean%"=="1" ( echo *         %project_path% : MAKE + CLEAN + BUILD 
)ELSE								 ( echo *         %project_path% : MAKE + BUILD )
echo **************************************************************************
echo -S ..\%project_path% -B ..\%make_path% "-GNMake Makefiles JOM" "-DCMAKE_BUILD_TYPE:STRING=%make_tag%" "-DCMAKE_PROJECT_INCLUDE_BEFORE:PATH=C:/Qt/Qt5.12.12/Tools/QtCreator/share/qtcreator/package-manager/auto-setup.cmake" "-DQT_QMAKE_EXECUTABLE:STRING=C:/Qt/Qt5.5.1/5.5/mingw492_32/bin/qmake.exe" "-DCMAKE_PREFIX_PATH:STRING=C:/Qt/Qt5.5.1/5.5/mingw492_32" "-DCMAKE_C_COMPILER:STRING=C:/Qt/Qt5.5.1/Tools/mingw492_32/bin/gcc.exe" "-DCMAKE_CXX_COMPILER:STRING=C:\Qt\Qt5.5.1\Tools\mingw492_32\bin\g++.exe"

"C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe" -S D:/Progetti/Unyco_master/argon2/argon2 -B D:/Progetti/Unyco_master/argon2/build-argon2-Desktop_Qt_5_5_1_MinGW_32bit-Release "-GNMake Makefiles JOM" "-DCMAKE_BUILD_TYPE:STRING=Release" "-DCMAKE_PROJECT_INCLUDE_BEFORE:PATH=C:/Qt/Qt5.12.12/Tools/QtCreator/share/qtcreator/package-manager/auto-setup.cmake" "-DQT_QMAKE_EXECUTABLE:STRING=C:/Qt/Qt5.5.1/5.5/mingw492_32/bin/qmake.exe" "-DCMAKE_PREFIX_PATH:STRING=C:/Qt/Qt5.5.1/5.5/mingw492_32" "-DCMAKE_C_COMPILER:STRING=C:/Qt/Qt5.5.1/Tools/mingw492_32/bin/gcc.exe" "-DCMAKE_CXX_COMPILER:STRING=C:\Qt\Qt5.5.1\Tools\mingw492_32\bin\g++.exe" "-DCMAKE_C_COMPILER_WORKS=1"

rem cmake -S ..\%project_path% -B ..\%make_path% "-GNMake Makefiles JOM" "-DCMAKE_BUILD_TYPE:STRING=%make_tag%" "-DCMAKE_PROJECT_INCLUDE_BEFORE:PATH=C:/Qt/Qt5.12.12/Tools/QtCreator/share/qtcreator/package-manager/auto-setup.cmake" "-DQT_QMAKE_EXECUTABLE:STRING=C:/Qt/Qt5.5.1/5.5/mingw492_32/bin/qmake.exe" "-DCMAKE_PREFIX_PATH:STRING=C:/Qt/Qt5.5.1/5.5/mingw492_32" "-DCMAKE_C_COMPILER:STRING=C:/Qt/Qt5.5.1/Tools/mingw492_32/bin/gcc.exe" "-DCMAKE_CXX_COMPILER:STRING=C:\Qt\Qt5.5.1\Tools\mingw492_32\bin\g++.exe"

cd ..\%make_path%

IF "%do_clean%"=="1" ( mingw32-make clean )
mingw32-make -j%NUMBER_OF_PROCESSORS% install

cd ..\
cd %project_path%
IF "%do_pause%"=="1" ( pause )