message(STATUS "Setting Unix configurations")

macro(os_set_flags)
    set(BACKEND RS2_USE_V4L2_BACKEND)
    set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   -fPIC -pedantic -g -D_BSD_SOURCE")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -pedantic -g -Wno-missing-field-initializers")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-switch -Wno-multichar -Wsequence-point -Wformat-security")

    add_definitions(-DUSE_SYSTEM_LIBUSB)

    execute_process(COMMAND ${CMAKE_C_COMPILER} -dumpmachine OUTPUT_VARIABLE MACHINE)
    if(${MACHINE} MATCHES "arm-linux-gnueabihf")
        set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   -mfpu=neon -mfloat-abi=hard -ftree-vectorize")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mfpu=neon -mfloat-abi=hard -ftree-vectorize")
    elseif(${MACHINE} MATCHES "aarch64-(.*-)?.*-.*")
        set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   -mstrict-align -ftree-vectorize")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mstrict-align -ftree-vectorize")
    else()
        set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   -mssse3")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mssse3")
        set(LRS_TRY_USE_AVX true)
    endif(${MACHINE} MATCHES "arm-linux-gnueabihf")

    if(NOT BUILD_WITH_OPENMP)
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pthread")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread")
    endif()

    if(APPLE)
        set(FORCE_LIBUVC ON)
        set(BUILD_WITH_TM2 ON)
    endif()
endmacro()

macro(os_target_config)
    find_package(PkgConfig)
    if(NOT PKG_CONFIG_FOUND)
        message(FATAL_ERROR "\n\n PkgConfig package is missing!\n\n")
    endif()

    pkg_search_module(LIBUSB1 REQUIRED libusb-1.0)
    if(LIBUSB1_FOUND)
        include_directories(SYSTEM ${LIBUSB1_INCLUDE_DIRS})
        link_directories(${LIBUSB1_LIBRARY_DIRS})
        list(APPEND librealsense_PKG_DEPS "libusb-1.0")
    else()
        message( FATAL_ERROR "Failed to find libusb-1.0" )
    endif(LIBUSB1_FOUND)

    target_include_directories(${LRS_TARGET} PRIVATE ${LIBUSB1_INCLUDE_DIRS})
    target_link_libraries(${LRS_TARGET} PRIVATE ${LIBUSB1_LIBRARIES})
endmacro()
