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

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
	message(STATUS "Setting build type to '${default_build_type}' as none was specified.")
	set(CMAKE_BUILD_TYPE "${default_build_type}" CACHE
		STRING "Choose the type of build." FORCE)
	# Set the possible values of build type for cmake-gui
	set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
		"Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

if (EXISTS "${CMAKE_SOURCE_DIR}/cmake")
	set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
		"${CMAKE_SOURCE_DIR}/cmake")
endif ()

# Set sanitizers
if (EXISTS "${CMAKE_SOURCE_DIR}/cmake/sanitizers")
	set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
		"${CMAKE_SOURCE_DIR}/cmake/sanitizers")
	set (SANITIZERS_FOUND ON)
endif ()


# Download dependencies
if (EXISTS "${CMAKE_SOURCE_DIR}/cmake/external")
	file(GLOB EXTERNAL_SUBDIR
		"${CMAKE_SOURCE_DIR}/cmake/external/*.cmake")

	foreach (DEPS ${EXTERNAL_SUBDIR})
		include(${DEPS})
	endforeach ()
endif ()

# Options
# You can achieve the same behavior by doing CC=clang CXX=clang++ cmake ..
option(USE_CLANG "Build application with clang" OFF)
# Depends on clang and llvm being installed
# cmake -DSANITIZE_ADDRESS=ON ..
# ./bin/<executable_name>
if (SANITIZERS_FOUND)
	option(SANITIZE_ADDRESS "Enable Address Sanitizer" OFF)
	option(SANITIZE_MEMORY "Enable Memory Sanitizer" OFF)
	option(SANITIZE_THREAD "Enable Thread Sanitizer" OFF)
	option(SANITIZE_UNDEFINED "Enable Undefined Behavior Sanitizer" OFF)
endif ()
option(ENABLE_TESTS "Build tests" OFF)
option(ENABLE_CLANG_TIDY "Use clang-tidy" OFF)

if (USE_CLANG)
	message(STATUS "Clang Compiler enabled")
	if (MSVC)
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
set (CMAKE_CXX_STANDARD 17)

# add flags to release mode
if (NOT MSVC)
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

if (SANITIZERS_FOUND)
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
