project(demo C)
cmake_minimum_required(VERSION 2.8)
# add own cmake modules to module path
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")

# we need to enable assembler language to be able to
# create the custom ELF section
enable_language(ASM-ATT)

# get Git info
include(GetGitInfo)
get_git_url(GIT_URL)
get_git_sha1(GIT_SHA1)

# create .note section file with Git version
configure_file(git-version.s.in git-version.s)

# create an executable
add_executable(demo main.c git-version.s)

