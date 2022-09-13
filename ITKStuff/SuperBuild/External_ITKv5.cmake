
#-----------------------------------------------------------------------------
# Get and build itk



set(proj ITK)  ## Use ITK convention of calling it ITK
set(ITK_REPOSITORY https://github.com/InsightSoftwareConsortium/ITK.git)
#set(ITK_REPOSITORY https://github.com/richardbeare/ITK.git)

# NOTE: it is very important to update the ITK_DIR path with the
# version number at the end of this file
set(ITK_TAG_COMMAND GIT_TAG 8be208ee1f04d09912523401e78ba7bb14a89d6f
 )

set( ITK_BUILD_SHARED_LIBS OFF )


file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${proj}-build/CMakeCacheInit.txt" "${ep_common_cache}" )

ExternalProject_Add(${proj}
  GIT_REPOSITORY ${ITK_REPOSITORY}
  ${ITK_TAG_COMMAND}
  UPDATE_COMMAND ""
  SOURCE_DIR ${proj}
  BINARY_DIR ${proj}-build
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
  --no-warn-unused-cli
  -C "${CMAKE_CURRENT_BINARY_DIR}/${proj}-build/CMakeCacheInit.txt"
  ${ep_common_args}
  ${ep_languages_args}
  -DBUILD_EXAMPLES:BOOL=OFF
  -DBUILD_TESTING:BOOL=OFF
  -DBUILD_SHARED_LIBS:BOOL=OFF
  -DCMAKE_SKIP_RPATH:BOOL=ON
  -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
  -DITK_LEGACY_REMOVE:BOOL=ON
  -DITK_BUILD_DEFAULT_MODULES:BOOL=ON
  -DModule_ParabolicMorphology=ON
  -DModule_ITKReview:BOOL=ON
  -DUSE_WRAP_ITK:BOOL=OFF
  -DINSTALL_WRAP_ITK_COMPATIBILITY:BOOL=OFF
  BUILD_COMMAND ${BUILD_COMMAND_STRING}
  DEPENDS
  ${ITK_DEPENDENCIES}
  )


ExternalProject_Get_Property(ITK install_dir)
set(ITK_DIR "${install_dir}/lib/cmake/ITK-5.2" )
