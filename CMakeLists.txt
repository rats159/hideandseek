cmake_minimum_required(VERSION 3.15)
project(HideAndSeek LANGUAGES C CXX)

option(DEVTOOLS "Enable dev tools" OFF)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

set(OUTPUT_DIR ${CMAKE_SOURCE_DIR}/out)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${OUTPUT_DIR})

include(FetchContent)

add_library(tinyfiledialogs STATIC
        ${CMAKE_SOURCE_DIR}/vendor/tinyfiledialogs/tinyfiledialogs.c)
target_include_directories(tinyfiledialogs PUBLIC
        ${CMAKE_SOURCE_DIR}/vendor/tinyfiledialogs)

FetchContent_Declare(
        raylib
        GIT_REPOSITORY https://github.com/raysan5/raylib.git
        GIT_TAG 5.5)
FetchContent_MakeAvailable(raylib)

file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS src/*.cpp)

add_executable(hideandseek ${SOURCES})

set(ASSETS_SRC ${CMAKE_SOURCE_DIR}/assets)
set(ASSETS_DST ${OUTPUT_DIR}/assets)

add_custom_command(
    TARGET hideandseek
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
            ${ASSETS_SRC}
            ${ASSETS_DST}
    COMMENT "Copying assets to ${ASSETS_DST}"
)

target_include_directories(hideandseek PRIVATE ${CMAKE_SOURCE_DIR}/vendor)

target_compile_options(hideandseek PRIVATE
    $<$<CXX_COMPILER_ID:GNU>:-Wall -Werror>
    $<$<CXX_COMPILER_ID:Clang>:-Wall -Werror>
    $<$<CXX_COMPILER_ID:MSVC>:/W4 /WX>
)

target_link_libraries(hideandseek PRIVATE raylib glfw tinyfiledialogs)

if (WIN32)
    target_link_libraries(hideandseek PRIVATE gdi32 winmm)
endif()

if (DEVTOOLS)
    target_compile_definitions(hideandseek PRIVATE DEVTOOLS)
endif()