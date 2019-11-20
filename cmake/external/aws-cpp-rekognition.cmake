include(ExternalProject)

# build directory
set(aws-rekog_PREFIX ${CMAKE_BINARY_DIR}/external/aws-rekog-prefix)
# install directory
set(aws-rekog_INSTALL ${CMAKE_BINARY_DIR}/external/aws-rekog-install)

# Dependencies of aws
if (UNIX)
	find_package (Threads REQUIRED)
	find_package (ZLIB REQUIRED)
	find_package (OpenSSL REQUIRED)
	find_package (CURL REQUIRED)
endif ()

set(_libs
		${aws-rekog_INSTALL}/lib/libaws-c-common.so
		${aws-rekog_INSTALL}/lib/libaws-c-event-stream.so
		${aws-rekog_INSTALL}/lib/libaws-checksums.so
		${aws-rekog_INSTALL}/lib/libaws-cpp-sdk-core.so
		${aws-rekog_INSTALL}/lib/libaws-cpp-sdk-rekognition.so
	)

ExternalProject_Add(
		aws-rekog
		PREFIX ${aws-rekog_PREFIX}
		GIT_REPOSITORY https://github.com/aws/aws-sdk-cpp
		GIT_TAG				 1.7.188
		GIT_SHALLOW		 1
		GIT_PROGRESS	 1
		UPDATE_DISCONNECTED TRUE
		CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
							-DCMAKE_INSTALL_PREFIX=${aws-rekog_INSTALL}
							-DBUILD_ONLY=rekognition
							-DENABLE_TESTING=OFF
							# -DBUILD_SHARED_LIBS=OFF
							# The generator is set from main generator
							# -G "Ninja"
							# -DCPP_STANDARD=${CXX_COMPILER_FLAG}
							# -DBUILD_DEPS=OFF
		BUILD_BYPRODUCTS ${_libs}
		INSTALL_COMMAND ""
	)

set(AWS_REKOG_FOUND TRUE)
set(AWS_REKOG_INCLUDE_DIRS ${aws-rekog_INSTALL}/include)
set(AWS_REKOG_LIBRARIES ${_libs})
set(AWS_REKOG_LIBRARY_DIRS ${aws-rekog_INSTALL}/lib)
set(AWS_REKOG_EXTERNAL TRUE)
