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

# Options
option(USE_CLANG "build application with clang" ON)
option(ENABLE_ASAN "Enable ASAN" OFF)
option(ENABLE_USAN "Enable USAN" OFF)
option(ENABLE_TSAN "Enable TSAN" OFF)
option(ENABLE_TESTS "Build tests" OFF)
option(ENABLE_CLANG_TIDY "Use clang-tidy" OFF)

if(ENABLE_ASAN)
	message(STATUS "ASAN enabled")
	set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=address")
endif()

if(ENABLE_USAN)
	message(STATUS "USAN enabled")
	set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=undefined")
endif()

if(ENABLE_TSAN)
	message(STATUS "TSAN enabled")
	set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=thread")
endif()

if (USE_CLANG)
	set(CMAKE_CXX_COMPILER "clang++" )
	set(CMAKE_AR           "llvm-ar" )
	set(CMAKE_LINKER       "llvm-ld" )
	set(CMAKE_NM           "llvm-nm" )
	set(CMAKE_OBJDUMP      "llvm-objdump" )
	set(CMAKE_RANLIB       "llvm-ranlib" )
endif (USE_CLANG)

if (ENABLE_CLANG_TIDY)
	message(STATUS "ASAN enabled")
	set(CMAKE_CXX_CLANG_TIDY clang-tidy;
		-p ${CMAKE_BINARY_DIR};
		-checks=*
		)
endif (ENABLE_CLANG_TIDY)

include(CheckCXXCompilerFlag)
check_cxx_compiler_flag("-std=c++17" COMPILER_SUPPORTS_CXX17)

# Build with c++17 support
if(COMPILER_SUPPORTS_CXX17)
	set(CMAKE_CXX_STANDARD 17)
else()
	message(FATAL_ERROR
		"The compiler ${CMAKE_CXX_COMPILER} has no C++17 support.")
endif()

# add flags to release mode
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

# Specify output directories.
set(EXECUTABLE_OUTPUT_PATH "${PROJECT_BINARY_DIR}/bin")

# Include custom macros to find Glog.
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
	"${CMAKE_CURRENT_SOURCE_DIR}/cmake")

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(RapidJSON REQUIRED)

find_package(GLog REQUIRED)

find_package(GTest REQUIRED)

find_package(Boost REQUIRED)

add_subdirectory("src")
add_subdirectory("docs")

if(ENABLE_TESTS)
	enable_testing()
	add_subdirectory("tests")
endif()

include (GNUInstallDirs)
install (TARGETS ExecutableName)
# Copy all config files to /etc
install (FILES
	GLOB "${CMAKE_SOURCE_DIR}/config/*.*"
	DESTINATION ${CMAKE_INSTALL_SYSCONFDIR}
	)
