@ECHO OFF

set project_path=RayIoBoardUploader
set install_path=C:\Raytec-Dev

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
	set make_tag=release
	set make_arguments=
) ELSE (
	set make_path=build-%project_path%-Desktop_Qt_5_5_1_MinGW_32bit-Debug
	set make_tag=debug
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
cd %make_path% 


echo **************************************************************************
IF "%do_clean%"=="1" ( echo *         %project_path% : MAKE + CLEAN + BUILD 
)ELSE								 ( echo *         %project_path% : MAKE + BUILD )
echo **************************************************************************
qmake ..\%project_path%\%project_path%.pro -r -spec win32-g++ %make_arguments%
lrelease.exe ..\%project_path%\%project_path%.pro
IF "%do_clean%"=="1" ( mingw32-make clean )
mingw32-make -j8 install

cd ..\
cd %project_path%
IF "%do_pause%"=="1" ( pause )