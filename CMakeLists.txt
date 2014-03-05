project(demo C)
cmake_minimum_required(VERSION 2.8)
# add own cmake modules to module path
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")

option(BUILDID_ENABLED  "If enabled the build-id will be embedded into all executables" ON)
option(SOURCEID_ENABLED "If enabled the source-id will be embedded into all executables" ON)

if (BUILDID_ENABLED)
    # The build-id is already built into the GNU linker,
    # we just need to enable it using the linker flags
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--build-id")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--build-id")
endif()

if (SOURCEID_ENABLED)
    # we need to enable assembler language to be able to
    # create the custom ELF section
    enable_language(ASM-ATT)

    # get Git info
    include(GetGitInfo)
    get_git_url(GIT_URL)
    get_git_sha1(GIT_SHA1)

    # create .note section file with Git version
    configure_file(git-version.s.in git-version.s)
    set(ADDITIONAL_SOURCES git-version.s)
endif()

# create an executable
add_executable(demo main.c ${ADDITIONAL_SOURCES})

