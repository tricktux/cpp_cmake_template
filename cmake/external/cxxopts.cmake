include(ExternalProject)

# build directory
set(cxxopts_PREFIX ${CMAKE_BINARY_DIR}/external/cxxopts-prefix)
# install directory
set(cxxopts_INSTALL ${CMAKE_BINARY_DIR}/external/cxxopts-install)

ExternalProject_Add(
		cxxopts
		PREFIX ${libnvc_PREFIX}
		GIT_REPOSITORY https://github.com/jarro2783/cxxopts
		GIT_TAG				 v2.2.0
		GIT_SHALLOW		 1
		GIT_PROGRESS	 1
		UPDATE_DISCONNECTED TRUE
		CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
							-DCMAKE_INSTALL_PREFIX=${cxxopts_INSTALL}
							-DCXXOPTS_BUILD_EXAMPLES=OFF
							-DCXXOPTS_BUILD_TESTS=OFF

		INSTALL_COMMAND ""
		LOG_DOWNLOAD 1
		LOG_INSTALL 1
	)

set(CXXOPTS_FOUND TRUE)
set(CXXOPTS_INCLUDE_DIRS ${cxxopts_INSTALL}/include)
set(CXXOPTS_EXTERNAL TRUE)
