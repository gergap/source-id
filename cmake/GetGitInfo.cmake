# Returns information about the current git working dir.
# At the moment this module provides two functions:
#
# get_git_url: Retrieves the URL of the remote "origin"
# get_git_sha1: Retrieves the SHA1 sum of HEAD
#
# This functions can be used to link the git version information
# into the executable.
#
# Copyright (C) 2014 Gerhard Gappmeier, ascolab GmbH

# find path to git executable
if(NOT GIT_FOUND)
    find_package(Git QUIET)
endif()

# Retrieve URL with the default remote "origin"
function(get_git_url _var)
    execute_process(
        COMMAND "${GIT_EXECUTABLE}" config --get remote.origin.url
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
        RESULT_VARIABLE res
        OUTPUT_VARIABLE out
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE)
        if(NOT res EQUAL 0)
            set(out "")
        endif()

        set(${_var} "${out}" PARENT_SCOPE)
endfunction()

# Get the current SHA1 of HEAD
function(get_git_sha1 _var)
    execute_process(
        COMMAND "${GIT_EXECUTABLE}" rev-list -n 1 HEAD
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
        RESULT_VARIABLE res
        OUTPUT_VARIABLE out
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE)
        if(NOT res EQUAL 0)
            set(out "")
        endif()

        set(${_var} "${out}" PARENT_SCOPE)
endfunction()

