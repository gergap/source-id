Source-Id Feature
=================

Description
-----------

When debugging executables or analyzing crash dumps a developer has always two
problems. Find the right debug symbols and find the right sources which match
the executable.

It is good practice to archive the debug symbols when ever you release a
product. Therefor it is important to build the executable with debug info (-g)
also in release mode (RelWithDebInfo for CMake users). The build-id feature of
GDB allows to featch the correct symbols for your executable automatically. See
http://randomascii.wordpress.com/2013/03/05/symbols-on-linux-update-fedora-fixes/
for more information on howto use build-ids.

To get the correct sources most people are creating tags in version control
system. When debugging an executable your need to extract the version
information of this executable, search for a tag for this version in the
version control system and check out this version. If everything works you have
the correct sources for your executable.

The source-id feature can automate this process and make it more reliable.
Similar to the build-id we embedded the current version which was used to build
the binary in a ELF .note section. GDB is enhanced to extract this information
from the executable during debugging an can fetch the sources automatically from
source server. GDB calls an external fetch script which can be customized by the
user. This way a user can configure how and where to fetch sources from. This
script can cache fetched files locally so that you don't need to fetch the same
file more than once. Therefore the script can generate a Sha1 sum of the file
contents.

What happens if the exact file version, which was used to built the executable
is not under version control? The bad news is you don't have the correct source
file. The good news is you can detect this. An additional option is to embeeded
the file hash for each source file in an additional section which gets archived
with the debug info. When the fetch script fetches sources from a server we can
compare this file hash with the embedded one and detect if the file is the
correct one.

Today GDB only detects changes of locale files based on the timestamp, so this
would a big improvement.

The source-lookup using the fetch-script in GDB will be an option which is
disabled by default. This way the normal developer can debug as usual without
getting annoyed by fetching attempts of GDB when you don't have a source server.
GDB will only call this external fetch-script if the source-lookup is enabled
and the executable being debugged contains source-id information.

Indexing-Part
-------------

With indexing we mean the process of embedding the version information of a VCS
(git, subversion, ...) into the executable. Therefore a new ELF section
".notes.gnu.source-id" was definied analogous to the existing
".note.gnu.build-id" (See
http://fedoraproject.org/wiki/Releases/FeatureBuildId).

The contents of the source-id section is as follows:

    vcs-type: a string specifying what VCS should be used (e.g. "git", "svn", "p4", ...)
    vcs-url: an URL specifying the repository where to get the sources from
      (e.g. "git://sourceware.org/git/binutils-gdb.git")
    vcs-version: a string specifying the version which was used to build the
      executable. With Git this could be the Git SHA1 sum e.g.
      "92c354d6227055e7ede82c9d56ebd5f90106273f", with subversion this could be the
      global revision counter. Note, because we only have one version field this must
      uniquely indentify the complete sources, which is the case for most modern VCS
      systems like Git and Subversion, but not for CVS, which has only file based revision
      numbers.

This section can be created simply using 'GNU as (assembler)':

        .section ".note.gnu.source-id", "a"
        .p2align 2          # 4 byte aligned
        .long 1f - 0f       # size of name field (not including padding)
        .long 3f - 2f       # size of description field (not including padding)
        .long 0x01234567    # note type (TODO: need to be registered at GNU)
    0:  .asciz "GNU"        # vendor name of this extension "GNU"
    1:  .p2align 2
    2:  .asciz "git"        # vcs-type
        .asciz "git@github.com:gergap/source-id.git"    # vcs-url
        .asciz "6191cbe2c470cbfc28674e0add730749cd207880"   # vcs-version
    3:  .p2align 2

This section can be generated during the build-process. Here is example using
CMake, but this also works using Make, shell scripts or whatever you are using to
build your projects.

CMake Example
-------------

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

To build the executable with the embedded version info you need to run

    cmake .
    make

You can view the result using readelf.

Listing all ELF notes
---------------------

    $> readelf -n demo
    Notes at offset 0x0000028c with length 0x00000020:
      Owner                 Data size	Description
      GNU                  0x00000010	NT_GNU_ABI_TAG (ABI version tag)
        OS: Linux, ABI: 2.6.16

    Notes at offset 0x000002ac with length 0x00000058:
      Owner                 Data size	Description
      GNU                  0x00000045	Unknown note type: (0x01234567)

As you can see the readelf utility cannot display the description filed of the
new note type, because it doesn't know it. But it shows you the type number and
size of the note.

Dumping the .note.gnu.source-id section
---------------------------------------

Using the option -p (--string-dump) your can dump the contents of your new
section to verify the results.

    $> readelf -p .note.gnu.source-id demo
    String dump of section '.note.gnu.source-id':
      [     4]  E
      [     8]  gE#GNU
      [    10]  git
      [    14]  git@git.ascolab.com:bla
      [    2c]  da72c625e7c1676afbce2c216c9b1aefdd7c9361

Integration in GDB
------------------

TODO

GDB fetch-source hook scripts
-----------------------------

TODO


