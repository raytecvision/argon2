cmake_minimum_required(VERSION 4.0)

project(Argon2 C)
set(ARGON2_VERSION 1.0)
if (NOT WIN32)
    set(BINARY_INSTALL_DIR /opt/raytec/dev/lib)
    set(LIBRARY_INSTALL_DIR /opt/raytec/dev/lib)
    set(INCLUDE_INSTALL_DIR /opt/raytec/dev/include/argon2)
else()
    if (MSVC)
        set(BINARY_INSTALL_DIR "C:/Raytec-Dev-3/msvc/x64/5.12.12/argon2/vc15/lib")
        set(LIBRARY_INSTALL_DIR "C:/Raytec-Dev-3/msvc/x64/5.12.12/argon2/vc15/lib")
        set(INCLUDE_INSTALL_DIR "C:/Raytec-Dev-3/msvc/x64/5.12.12/argon2/include")
    else()
        set(BINARY_INSTALL_DIR "C:/Raytec-Dev-3/mingw/x86/5.5.1/argon2/mingw/bin")
        set(LIBRARY_INSTALL_DIR "C:/Raytec-Dev-3/mingw/x86/5.5.1/argon2/mingw/bin")
        set(INCLUDE_INSTALL_DIR "C:/Raytec-Dev-3/mingw/x86/5.5.1/argon2/include")
    endif()
endif()
set(CMAKE_C_STANDARD 90)
set(CMAKE_C_STANDARD_REQUIRED ON)
enable_testing()

include(CheckCSourceCompiles)
find_package(Threads REQUIRED)

add_library(argon2-interface INTERFACE)
target_include_directories(argon2-interface INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

add_library(argon2-internal INTERFACE)
target_include_directories(argon2-internal INTERFACE lib lib/blake2)
target_link_libraries(argon2-internal INTERFACE argon2-interface)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(LIBRARY_NAME argon2d)
    message("-- Bullet: Debug build")
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(LIBRARY_NAME argon2)
    message("-- Bullet: Release build")
endif()

add_library(${LIBRARY_NAME} SHARED
    lib/argon2.c
    lib/core.c
    lib/encoding.c
    lib/genkat.c
    lib/impl-select.c
    lib/thread.c
    lib/blake2/blake2.c
)

target_link_libraries(${LIBRARY_NAME}
    PUBLIC argon2-interface ${CMAKE_THREAD_LIBS_INIT}
    PRIVATE argon2-internal
)

set_property(TARGET ${LIBRARY_NAME} PROPERTY VERSION ${Upstream_VERSION})
set_property(TARGET ${LIBRARY_NAME} PROPERTY SOVERSION 1)
set_property(TARGET ${LIBRARY_NAME} PROPERTY INTERFACE_ARGON2_MAJOR_VERSION 1)
set_property(TARGET ${LIBRARY_NAME} APPEND PROPERTY
    COMPATIBLE_INTERFACE_STRING ARGON2_MAJOR_VERSION
)

if(CMAKE_SYSTEM_PROCESSOR STREQUAL x86_64)
    function(add_feature_impl FEATURE GCC_FLAG DEF)
        add_library(argon2-${FEATURE} STATIC
            arch/x86_64/lib/argon2-${FEATURE}.c
        )
        target_link_libraries(argon2-${FEATURE} PRIVATE argon2-internal)
        set_target_properties(argon2-${FEATURE}
            PROPERTIES POSITION_INDEPENDENT_CODE True
        )

        message("-- Detecting feature '${FEATURE}'...")
        file(READ arch/x86_64/src/test-feature-${FEATURE}.c SOURCE_CODE)

        # try without flag:
        check_c_source_compiles("${SOURCE_CODE}" FEATURE_${FEATURE}_NOFLAG)
        set(HAS_FEATURE ${FEATURE_${FEATURE}_NOFLAG})
        if(NOT "${HAS_FEATURE}")
            # try with -m<feature> flag:
            set(CMAKE_REQUIRED_FLAGS ${GCC_FLAG})
            check_c_source_compiles("${SOURCE_CODE}" FEATURE_${FEATURE}_FLAG)
            set(CMAKE_REQUIRED_FLAGS "")

            set(HAS_FEATURE ${FEATURE_${FEATURE}_FLAG})
            if(${HAS_FEATURE})
                target_compile_options(argon2-${FEATURE} PRIVATE ${GCC_FLAG})
            endif()
        endif()

        if(${HAS_FEATURE})
            message("-- Feature '${FEATURE}' detected!")
            target_compile_definitions(argon2-${FEATURE} PRIVATE ${DEF})
        endif()
        target_link_libraries(${LIBRARY_NAME} PUBLIC argon2-${FEATURE})
    endfunction()

    target_include_directories(argon2-internal INTERFACE arch/x86_64/lib)

    add_feature_impl(sse2    -msse2    HAVE_SSE2)
    add_feature_impl(ssse3   -mssse3   HAVE_SSSE3)
    add_feature_impl(xop     -mxop     HAVE_XOP)
    add_feature_impl(avx2    -mavx2    HAVE_AVX2)
    add_feature_impl(avx512f -mavx512f HAVE_AVX512F)

    target_sources(${LIBRARY_NAME} PRIVATE
        arch/x86_64/lib/argon2-arch.c
        arch/x86_64/lib/cpu-flags.c
    )
else()
    target_sources(${LIBRARY_NAME} PRIVATE
        arch/generic/lib/argon2-arch.c
    )
endif()

add_executable(argon2-exec src/run.c)
target_link_libraries(argon2-exec ${LIBRARY_NAME} argon2-internal)
target_include_directories(argon2-exec PRIVATE src)
set_target_properties(argon2-exec PROPERTIES OUTPUT_NAME ${LIBRARY_NAME})

add_executable(argon2-genkat src/genkat.c)
target_include_directories(argon2-genkat PRIVATE src)
target_link_libraries(argon2-genkat ${LIBRARY_NAME})

add_executable(argon2-bench2 src/bench2.c)
target_include_directories(argon2-bench2 PRIVATE src)
target_link_libraries(argon2-bench2 ${LIBRARY_NAME})

add_executable(argon2-test tests/test.c)
target_include_directories(argon2-test PRIVATE tests)
target_link_libraries(argon2-test ${LIBRARY_NAME})

add_test(test argon2-test)

install(TARGETS ${LIBRARY_NAME} DESTINATION ${LIBRARY_INSTALL_DIR})
install(FILES
    include/argon2.h
    DESTINATION ${INCLUDE_INSTALL_DIR}
)
install(TARGETS argon2-exec DESTINATION ${BINARY_INSTALL_DIR})
