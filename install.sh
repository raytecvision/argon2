#!/bin/bash
# set -x

if [ "$#" -ne "1" ]; then
	echo "Expected 1 argument, got $#" >&2
	usage
	exit 2
fi

if [ $1 = "debug" ]; then
	make_tag=Debug
	make_arguments="CONFIG+=debug"
else
	make_tag=Release
	make_arguments=""
fi
	
	
project_name=${PWD##*/}
echo ${project_name}
build_path=build-${project_name}-Desktop-${make_tag}

cd ..
cd ${build_path}
make install
