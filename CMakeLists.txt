# File:           CMakeLists.txt
# Description:     Code Description
# Author:		    Reinaldo Molina
# Email:          rmolin88 at gmail dot com
# Revision:	    0.0.0
# Created:        Tue Mar 05 2019 06:13
# Last Modified:  Tue Mar 05 2019 06:13

cmake_minimum_required(VERSION 3.1)

# Set ProjectName
project(ProjectName)

# This points to the build directory
message( STATUS "CMAKE_BINARY_DIR: " ${CMAKE_BINARY_DIR} )

# Set a default build type if none was specified
set(default_build_type "Release")
if(EXISTS "${CMAKE_SOURCE_DIR}/.git")
	set(default_build_type "Debug")
endif()

if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
	message(STATUS "Setting build type to '${default_build_type}' as none was specified.")
	set(CMAKE_BUILD_TYPE "${default_build_type}" CACHE
		STRING "Choose the type of build." FORCE)
	# Set the possible values of build type for cmake-gui
	set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
		"Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

set (_modules
		"${CMAKE_SOURCE_DIR}/cmake"
		"${CMAKE_SOURCE_DIR}/cmake/sanitizers"
		"${CMAKE_SOURCE_DIR}/cmake/external"
	)

set (CMAKE_MODULE_PATH _modules)

# Options
# You can achieve the same behavior by doing CC=clang CXX=clang++ cmake ..
option(USE_CLANG "Build application with clang" OFF)
# Depends on clang and llvm being installed
# cmake -DSANITIZE_ADDRESS=ON ..
# ./bin/<executable_name>
option(SANITIZE_ADDRESS "Enable Address Sanitizer" OFF)
option(SANITIZE_MEMORY "Enable Memory Sanitizer" OFF)
option(SANITIZE_THREAD "Enable Thread Sanitizer" OFF)
option(SANITIZE_UNDEFINED "Enable Undefined Behavior Sanitizer" OFF)
option(SANITIZE_LINK_STATIC "Try to link static against sanitizers." OFF)

option(ENABLE_TESTS "Build tests" OFF)
option(ENABLE_CLANG_TIDY "Use clang-tidy" OFF)

# Download dependencies
if (EXISTS "${CMAKE_SOURCE_DIR}/cmake/external")
	file(GLOB EXTERNAL_DEPS
		"${CMAKE_SOURCE_DIR}/cmake/external/*.cmake")

	foreach (DEPS ${EXTERNAL_DEPS})
		include(${DEPS})
	endforeach ()
endif ()

if (USE_CLANG)
	message(STATUS "Clang Compiler enabled")
	if (MSVC)
		set(CMAKE_C_COMPILER	"clang-cl" )
		set(CMAKE_CXX_COMPILER "clang-cl" )
	else ()
		set(CMAKE_C_COMPILER	"clang" )
		set(CMAKE_CXX_COMPILER "clang++" )
	endif ()
endif ()

if (ENABLE_CLANG_TIDY)
	message(STATUS "ASAN enabled")
	set(CMAKE_CXX_CLANG_TIDY clang-tidy;
		-p ${CMAKE_BINARY_DIR};
		-checks=*
		)
endif ()

# Build with c++17 support
include(CheckCXXCompilerFlag)
set (_cpp_version "17")
if (MSVC AND MSVC_VERSION GREATER_EQUAL "1900")
	check_cxx_compiler_flag("/std:c++latest" _cpp_latest_flag_supported)
	if (_cpp_latest_flag_supported)
		add_compile_options("/std:c++latest")
	endif()
else ()
	check_cxx_compiler_flag("-std=c++${_cpp_version}"
		_cpp_latest_flag_supported)
	if (_cpp_latest_flag_supported)
		add_compile_options("-std=c++${_cpp_version}")
	endif()
endif()

# add flags to release mode
if (MSVC)
	add_compile_options(/W4 /WX)
else ()
	set(CMAKE_CXX_FLAGS_RELEASE "$ENV{CXXFLAGS}")
	set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")
	set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -fno-strict-aliasing")
	set(CMAKE_CXX_FLAGS_RELEASE
		"${CMAKE_CXX_FLAGS_RELEASE} -Wall -Wfatal-errors -Wextra -Wunused -Werror")

	set(CMAKE_CXX_FLAGS_DEBUG "$ENV{CXXFLAGS}")
	set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0")

	set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g3 -ggdb3 -pedantic")
	set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fno-strict-aliasing")
	set(CMAKE_CXX_FLAGS_DEBUG
		"${CMAKE_CXX_FLAGS_DEBUG} -Wall -Wextra -Wunused -Werror")
endif ()

# Specify output directories.
set(EXECUTABLE_OUTPUT_PATH "${PROJECT_BINARY_DIR}/bin")

# Include custom macros to find Glog.
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# find_package(RapidJSON REQUIRED)

# find_package(GLog REQUIRED)

# find_package(GTest REQUIRED)

# find_package(Boost REQUIRED)

if (SANITIZE_ADDRESS OR SANITIZE_MEMORY OR SANITIZE_THREAD OR
		SANITIZE_UNDEFINED)
	find_package(Sanitizers REQUIRED)
endif ()

add_subdirectory("src")
# TODO fix doxygen
# add_subdirectory("docs")

if(ENABLE_TESTS AND EXISTS "${CMAKE_SOURCE_DIR}/tests")
	enable_testing()
	add_subdirectory("tests")
endif()

include (GNUInstallDirs)
# install (TARGETS ExecutableName)
# Copy all config files to /etc
if (EXISTS "${CMAKE_SOURCE_DIR}/config")
	install (FILES
			GLOB "${CMAKE_SOURCE_DIR}/config/*.*"
			DESTINATION ${CMAKE_INSTALL_SYSCONFDIR}
		)
endif ()
