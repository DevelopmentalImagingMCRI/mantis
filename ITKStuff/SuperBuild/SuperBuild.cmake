find_package(Git REQUIRED)

#-----------------------------------------------------------------------------
# CTest Related Settings
#-----------------------------------------------------------------------------
set(BUILDNAME "NoBuldNameGiven")
set(SITE      "NoSiteGiven")
option( BUILD_TESTING "Turn on Testing for MANTiS" ON )


enable_language(C)
enable_language(CXX)

#-----------------------------------------------------------------------------
# Platform check
#-----------------------------------------------------------------------------
set(PLATFORM_CHECK true)
if(PLATFORM_CHECK)
  # See CMake/Modules/Platform/Darwin.cmake)
  #   6.x == Mac OSX 10.2 (Jaguar)
  #   7.x == Mac OSX 10.3 (Panther)
  #   8.x == Mac OSX 10.4 (Tiger)
  #   9.x == Mac OSX 10.5 (Leopard)
  #  10.x == Mac OSX 10.6 (Snow Leopard)
  if (DARWIN_MAJOR_VERSION LESS "9")
    message(FATAL_ERROR "Only Mac OSX >= 10.5 are supported !")
  endif()
endif()

#-----------------------------------------------------------------------------
# Update CMake module path
#------------------------------------------------------------------------------

set(CMAKE_MODULE_PATH
  ${CMAKE_SOURCE_DIR}/SuperBuild
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_MODULE_PATH}
  )

include(PreventInSourceBuilds)
include(PreventInBuildInstalls)
include(VariableList)


#-----------------------------------------------------------------------------
# Prerequisites
#------------------------------------------------------------------------------
#
set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_BINARY_DIR} CACHE PATH "Where all the prerequisite libraries go" FORCE)

# Compute -G arg for configuring external projects with the same CMake generator:
if(CMAKE_EXTRA_GENERATOR)
  set(gen "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
else()
  set(gen "${CMAKE_GENERATOR}")
endif()


#-----------------------------------------------------------------------------
# MANTiS options
#------------------------------------------------------------------------------

# Set a default build type if none was specified
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

# Default to build shared libraries off


#-----------------------------------------------------------------------------
# Setup build type
#------------------------------------------------------------------------------

# By default, let's build as Release
if(NOT DEFINED CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release")
endif()

# let a dashboard override the default.
if(CTEST_BUILD_CONFIGURATION)
  set(CMAKE_BUILD_TYPE "${CTEST_BUILD_CONFIGURATION}")
endif()

#-------------------------------------------------------------------------
# augment compiler flags
#-------------------------------------------------------------------------
include(CompilerFlagSettings)

# Don't think this will matter for MBWSS - leave it anyway
# the hidden visibility for inline methods should be consistent between ITK and SimpleITK
if(NOT WIN32 AND CMAKE_COMPILER_IS_GNUCXX AND BUILD_SHARED_LIBS)
  check_cxx_compiler_flag("-fvisibility-inlines-hidden" CXX_HAS-fvisibility-inlines-hidden)
  if( CXX_HAS-fvisibility-inlines-hidden )
    set ( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility-inlines-hidden" )
  endif()
endif()

#------------------------------------------------------------------------------
# BuildName used for dashboard reporting
#------------------------------------------------------------------------------
if(NOT BUILDNAME)
  set(BUILDNAME "Unknown-build" CACHE STRING "Name of build to report to dashboard")
endif()


#------------------------------------------------------------------------------
# WIN32 /bigobj is required for windows builds because of the size of
#------------------------------------------------------------------------------
if (MSVC)
  # some object files (CastImage for instance)
  set ( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /bigobj" )
  set ( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /bigobj" )
  # Avoid some warnings
  add_definitions ( -D_SCL_SECURE_NO_WARNINGS )
endif()

#------------------------------------------------------------------------------
# Setup build locations.
#------------------------------------------------------------------------------
if(NOT SETIFEMPTY)
  macro(SETIFEMPTY) # A macro to set empty variables to meaninful defaults
    set(KEY ${ARGV0})
    set(VALUE ${ARGV1})
    if(NOT ${KEY})
      set(${ARGV})
    endif(NOT ${KEY})
  endmacro(SETIFEMPTY KEY VALUE)
endif(NOT SETIFEMPTY)


#------------------------------------------------------------------------------
# Common Build Options to pass to all subsequent tools
#------------------------------------------------------------------------------
list( APPEND ep_common_list
  MAKECOMMAND
  CMAKE_BUILD_TYPE

  CMAKE_C_COMPILER
  CMAKE_C_COMPILER_ARG1

  CMAKE_C_FLAGS
  CMAKE_C_FLAGS_DEBUG
  CMAKE_C_FLAGS_MINSIZEREL
  CMAKE_C_FLAGS_RELEASE
  CMAKE_C_FLAGS_RELWITHDEBINFO

  CMAKE_CXX_COMPILER
  CMAKE_CXX_COMPILER_ARG1

  CMAKE_CXX_FLAGS
  CMAKE_CXX_FLAGS_DEBUG
  CMAKE_CXX_FLAGS_MINSIZEREL
  CMAKE_CXX_FLAGS_RELEASE
  CMAKE_CXX_FLAGS_RELWITHDEBINFO

  CMAKE_EXE_LINKER_FLAGS
  CMAKE_EXE_LINKER_FLAGS_DEBUG
  CMAKE_EXE_LINKER_FLAGS_MINSIZEREL
  CMAKE_EXE_LINKER_FLAGS_RELEASE
  CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO
  CMAKE_MODULE_LINKER_FLAGS
  CMAKE_MODULE_LINKER_FLAGS_DEBUG
  CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL
  CMAKE_MODULE_LINKER_FLAGS_RELEASE
  CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO
  CMAKE_SHARED_LINKER_FLAGS
  CMAKE_SHARED_LINKER_FLAGS_DEBUG
  CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL
  CMAKE_SHARED_LINKER_FLAGS_RELEASE
  CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO

  CMAKE_GENERATOR
  CMAKE_EXTRA_GENERATOR
  MEMORYCHECK_COMMAND_OPTIONS
  MEMORYCHECK_SUPPRESSIONS_FILE
  MEMORYCHECK_COMMAND
  SITE
  BUILDNAME )

if( APPLE )
  list( APPEND ep_common_list
    CMAKE_OSX_SYSROOT
    CMAKE_OSX_DEPLOYMENT_TARGET )
endif()

VariableListToArgs( ep_common_list ep_common_args )

if( APPLE )
  list( APPEND ep_common_list CMAKE_OSX_ARCHITECTURES )
endif()
VariableListToCache( ep_common_list ep_common_cache )

list( APPEND ep_common_args
  -DBUILD_EXAMPLES:BOOL=OFF
)

#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
include(ExternalProject)
#------------------------------------------------------------------------------
# ITK
#------------------------------------------------------------------------------

set(ITK_WRAPPING OFF CACHE BOOL "Turn OFF wrapping ITK with WrapITK" ADVANCED)
if(ITK_WRAPNG)
  list(APPEND ITK_DEPENDENCIES Swig)
endif()
if(ITK_USE_FFTW)
  list(APPEND ITK_DEPENDENCIES fftw)
endif()
include(External_ITKv5)
list(APPEND ${CMAKE_PROJECT_NAME}_DEPENDENCIES ITK)


#------------------------------------------------------------------------------
# List of external projects
#------------------------------------------------------------------------------
set(external_project_list  ITK )

#-----------------------------------------------------------------------------
# Dump external project dependencies
#-----------------------------------------------------------------------------
set(ep_dependency_graph "# External project dependencies")
foreach(ep ${external_project_list})
  set(ep_dependency_graph "${ep_dependency_graph}\n${ep}:${${ep}_DEPENDENCIES}")
endforeach()
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/ExternalProjectDependencies.txt "${ep_dependency_graph}\n")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/MANTiS-build/CMakeCacheInit.txt" "${ep_common_cache}" )

set(proj MANTiS )

ExternalProject_Add(${proj}
  DOWNLOAD_COMMAND ""
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/..
  BINARY_DIR MANTiS-build
  INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    --no-warn-unused-cli
    -C "${CMAKE_CURRENT_BINARY_DIR}/MANTiS-build/CMakeCacheInit.txt"
    ${ep_common_args}
    -DBUILD_SHARED_LIBS:BOOL=OFF
    -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}\ ${CXX_ADDITIONAL_WARNING_FLAGS}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=<BINARY_DIR>/lib
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=<BINARY_DIR>/lib
    -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=<BINARY_DIR>/bin
    -DCMAKE_BUNDLE_OUTPUT_DIRECTORY:PATH=<BINARY_DIR>/bin
    ${ep_languages_args}
    # ITK
    -DITK_DIR:PATH=${ITK_DIR}
    -DBUILD_TESTING:BOOL=${BUILD_TESTING}
  DEPENDS ${${CMAKE_PROJECT_NAME}_DEPENDENCIES}
)

ExternalProject_Add_Step(${proj} forcebuild
  COMMAND ${CMAKE_COMMAND} -E remove
    ${CMAKE_CURRENT_BUILD_DIR}/${proj}-prefix/src/${proj}-stamp/${prog}-build
  DEPENDEES configure
  DEPENDERS build
  ALWAYS 1
)


