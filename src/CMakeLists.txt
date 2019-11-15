# All the source files for the bot.

file(GLOB SOURCES "*.cpp")

include_directories(${CMAKE_SOURCE_DIR}/inc)

if (CXXOPTS_FOUND)
	include_directories(${CXXOPTS_INCLUDE_DIRS})
endif ()

if (GLOG_FOUND)
	include_directories(SYSTEM "${GLOG_INCLUDE_DIRS}")
endif ()

if (RAPIDJSON_INCLUDE_DIRS)
	include_directories(SYSTEM "${RAPIDJSON_INCLUDE_DIRS}")
endif ()

# Show more warnings at compiletime.
if (MSVC)
    # FIXME: put Windows specific options here.
endif ()

# Set ExecutableName.
add_executable(ExecutableName ${SOURCES})
# Depends on external builds
# This way you can use make -j
add_dependencies(ExecutableName cxxopts)
if (SANITIZERS_FOUND)
	add_sanitizers(ExecutableName)
endif ()

if (GLOG_FOUND)
	target_link_libraries(ExecutableName ${GLOG_LIBRARIES})
endif ()

if (APPLE)
	target_link_libraries(ExecutableName "-framework Carbon")
endif ()

# Linux specific.
if (UNIX AND NOT APPLE)
	target_link_libraries(ExecutableName pthread dl)
endif ()
