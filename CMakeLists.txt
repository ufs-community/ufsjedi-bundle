# (C) Copyright 2021-2021 NOAA

# ##########
# ufs-bundle
# ##########

cmake_minimum_required( VERSION 3.12 FATAL_ERROR )

find_package( ecbuild 3.5 REQUIRED HINTS ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/../ecbuild)

project( ufs-bundle VERSION 1.1.0 LANGUAGES C CXX Fortran )

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include( ecbuild_bundle )

set(DEPEND_LIB_ROOT ${CMAKE_CURRENT_BINARY_DIR}/Depends)
list(APPEND CMAKE_PREFIX_PATH ${DEPEND_LIB_ROOT})
message("prefix path is ${CMAKE_PREFIX_PATH}")

# Default release mode
set( ECBUILD_DEFAULT_BUILD_TYPE Release )

# Enable MPI
set( ENABLE_MPI ON CACHE BOOL "Compile with MPI")
set( ENABLE_OMP ON CACHE BOOL "Compile with OpenMP")

# Use external jedi-cmake or build in bundle
if(DEFINED ENV{jedi_cmake_ROOT})
  include( $ENV{jedi_cmake_ROOT}/share/jedicmake/Functions/git_functions.cmake )
else()
  ecbuild_bundle( PROJECT jedicmake GIT "https://github.com/jcsda-internal/jedi-cmake.git" TAG 1.4.0 UPDATE RECURSIVE )
  include( jedicmake/cmake/Functions/git_functions.cmake )
endif()

# ECMWF libs
# ----------
option("BUNDLE_SKIP_ECKIT" "Don't build eckit" "ON" ) # Skip eckit build unless user passes -DBUNDLE_SKIP_ECKIT=OFF
option("BUNDLE_SKIP_FCKIT" "Don't build fckit" "ON") # Skip fckit build unless user passes -DBUNDLE_SKIP_FCKIT=OFF
option("BUNDLE_SKIP_ATLAS" "Don't build atlas" "ON") # Skip atlas build unless user passes -DBUNDLE_SKIP_ATLAS=OFF

ecbuild_bundle( PROJECT eckit GIT "https://github.com/ecmwf/eckit.git" TAG 1.20.2 )
ecbuild_bundle( PROJECT fckit GIT "https://github.com/ecmwf/fckit.git" TAG 0.9.5 )
ecbuild_bundle( PROJECT atlas GIT "https://github.com/ecmwf/atlas.git" TAG 0.31.1 )

# External FMS
find_package(FMS 2022.04 REQUIRED COMPONENTS R4 R8)

if(UFS_APP MATCHES "^(S2S)$" OR UFS_APP MATCHES "^(NG-GODAS)$")
  ecbuild_bundle( PROJECT gsw GIT "https://github.com/jcsda-internal/GSW-Fortran.git" TAG 1a02ebaf6f7a4e9f2c2d2dd973fb050e697bcc74 )  # develop on jan 28
endif()

# Core JEDI repositories
# ----------------------
ecbuild_bundle( PROJECT oops  GIT "https://github.com/jcsda-internal/oops.git"  TAG 0932772f4b20b0defedfb12e31a0c17c18caac71 ) # develop on feb 1
ecbuild_bundle( PROJECT vader GIT "https://github.com/jcsda-internal/vader.git" TAG 3c8fc58ed67c013a955ca7d8f8d2346f2844ac96 ) # develop on jan 28
ecbuild_bundle( PROJECT saber GIT "https://github.com/jcsda-internal/saber.git" TAG 1203356523b123654a8871846a55a06ed26b7247 ) # develop on jan 28
ecbuild_bundle( PROJECT ioda  GIT "https://github.com/jcsda-internal/ioda.git"  TAG 39ab4dd1dfe737f71385af802c2b5c67c2ef8efc ) # develop on jan 28
ecbuild_bundle( PROJECT ufo   GIT "https://github.com/jcsda-internal/ufo.git"   TAG ab106a84c770414a3edf9dacabeadea5d70d9edf ) # develop on jan 28

# Options for building with certain models
# ----------------------------------------
set(UFS_APP "ATM" CACHE STRING "Choose the UFS Application")
set_property(CACHE UFS_APP PROPERTY STRINGS "ATM" "NG-GODAS" "S2S")
if(NOT UFS_APP MATCHES "^(ATM|NG-GODAS|S2S)$")
  ecbuild_error("Valid options for -DUFS_APP are ATM|NG-GODAS|S2S")
endif()
ecbuild_info("Building with UFS application: ${UFS_APP}")
set(FV3_FORECAST_MODEL "UFS")

# fv3-jedi linear model
# ---------------------
ecbuild_bundle( PROJECT fv3-jedi-lm GIT "https://github.com/jcsda-internal/fv3-jedi-linearmodel.git" BRANCH feature/ufs_dom )  # updated from develop on nov 22, develop hasn't changed by jan 28

include_directories(${DEPEND_LIB_ROOT}/include_r8)
link_directories(${DEPEND_LIB_ROOT}/lib)

include( ExternalProject )

# Needed to get correct OpenMP link libraries on macOS
set(UFS_CMAKE_EXE_LINKER_FLAGS "-L${CMAKE_CURRENT_BINARY_DIR}/lib")
find_package(OpenMP REQUIRED)
if(APPLE)
  set(UFS_CMAKE_EXE_LINKER_FLAGS "${UFS_CMAKE_EXE_LINKER_FLAGS} ${OpenMP_libomp_LIBRARY} ${OpenMP_libomp_LIBRARY}")
endif()
message (STATUS "UFS_CMAKE_EXE_LINKER_FLAGS: ${UFS_CMAKE_EXE_LINKER_FLAGS}")

ExternalProject_Add(ufs-weather-model
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/ufs-weather-model
  GIT_REPOSITORY https://github.com/climbfuji/ufs-weather-model
  GIT_SUBMODULES_RECURSE TRUE
  GIT_TAG feature/consolidate_dom_update_20230117  # updated from develop on Jan 17
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ufs-weather-model
  UPDATE_DISCONNECTED ON
  INSTALL_DIR ${DEPEND_LIB_ROOT}
  CMAKE_ARGS -DCMAKE_C_FLAGS=-fPIC -DCMAKE_Fortran_FLAGS=-fPIC -DCMAKE_CXX_FLAGS=-fPIC -DCCPP_SUITES=FV3_GFS_v16,FV3_GFS_v16_coupled,FV3_GFS_v15p2 -DCMAKE_EXE_LINKER_FLAGS=${UFS_CMAKE_EXE_LINKER_FLAGS} -DCMAKE_C_COMPILER=${MPI_C_COMPILER} -DCMAKE_CXX_COMPILER=${MPI_CXX_COMPILER} -DCMAKE_Fortran_COMPILER=${MPI_Fortran_COMPILER} -DCMAKE_PREFIX_PATH=${CMAKE_CURRENT_BINARY_DIR}/gsw -DREPRO=ON -DOPENMP=ON -DINLINE_POST=OFF -DMULTI_GASES=OFF -DMPI=ON -DAPP=${UFS_APP} -DCMAKE_INSTALL_PREFIX=${DEPEND_LIB_ROOT}
  INSTALL_COMMAND make install
  BUILD_ALWAYS FALSE
  )

if(UFS_APP MATCHES "^(S2S)$" OR UFS_APP MATCHES "^(NG-GODAS)$")
  add_dependencies(ufs-weather-model gsw)
endif()
add_library( ufs IMPORTED STATIC)
add_library( cdeps IMPORTED STATIC)
add_library( cmeps IMPORTED STATIC)
add_library( ccpp IMPORTED STATIC)
add_library( stochastic_physics IMPORTED STATIC)
add_library( fv3atm IMPORTED STATIC)
add_library( ccppphys IMPORTED STATIC)
add_library( mom6 IMPORTED STATIC)
set_target_properties( ufs PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/lib/libufs.a)
set_target_properties( cdeps PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/lib/libcdeps.a)
set_target_properties( cmeps PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/lib/libcmeps.a)
set_target_properties(ccpp PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/lib/libccpp_framework.a)
set_target_properties(stochastic_physics PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/lib/libstochastic_physics.a)
set_target_properties(fv3atm PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/lib/libfv3atm.a)
set_target_properties(ccppphys PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/lib/libccpp_physics.a)
set_target_properties(mom6 PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/lib/libmom6.a)

if(UFS_APP MATCHES "^(S2S)$")
  # fv3-jedi and associated repositories
  # ------------------------------------
  ecbuild_bundle( PROJECT femps    GIT "https://github.com/jcsda-internal/femps.git"    TAG 1.2.0 )
  ecbuild_bundle( PROJECT fv3-jedi GIT "https://github.com/jcsda-internal/fv3-jedi.git" BRANCH feature/ufs_dom )  # updated from develop on jan28
  ecbuild_bundle( PROJECT soca     GIT "https://github.com/jcsda-internal/soca.git"     BRANCH feature/ufs_dom )  # updated from develop on jan28
  add_dependencies(soca ufs-weather-model)
elseif(UFS_APP MATCHES "^(NG-GODAS)$")
  ecbuild_bundle( PROJECT soca     GIT "https://github.com/jcsda-internal/soca.git" BRANCH feature/ufs_dom )  # updated from develop on jan28
  add_dependencies(soca ufs-weather-model)
elseif(UFS_APP MATCHES "^(ATM)$")
  ecbuild_bundle( PROJECT femps    GIT "https://github.com/jcsda-internal/femps.git"    TAG 1.2.0 )
  ecbuild_bundle( PROJECT fv3-jedi GIT "https://github.com/jcsda-internal/fv3-jedi.git" BRANCH feature/ufs_dom )  # updated from develop on jan28
else()
  message(FATAL_ERROR "ufs-bundle unknown UFS_APP ${UFS_APP}")
endif()


# ioda, ufo and fv3-jedi test data
#----------------------------------------

# If IODA branch is being built set GIT_BRANCH_FUNC to IODA's current branch.
# If a tagged version of IODA is being built set GIT_TAG_FUNC to ioda's current tag. In this case,
# IODA test files will be download from UCAR DASH and ioda-data repo will not be cloned.
# When LOCAL_PATH_JEDI_TESTFILES is set to the directory of IODA test files stored
# in a local directory, ioda-data repo will not be cloned

find_branch_name(REPO_DIR_NAME ioda)
# When LOCAL_PATH_JEDI_TESTFILES is set to the directory of IODA test files stored
# in a local directory, ioda-data repo will not be cloned
if( NOT DEFINED ENV{LOCAL_PATH_JEDI_TESTFILES} AND NOT DEFINED ${GIT_TAG_FUNC} )
  ecbuild_bundle( PROJECT ioda-data GIT "https://github.com/JCSDA-internal/ioda-data.git" TAG 3b4c1ba80a7cb9ae132d74c715492eae36d9d87f ) # develop on jan 28
endif()

# If IODA's current branch is available in ioda-data repo, that branch will be checked out
branch_checkout (REPO_DIR_NAME ioda-data
                 BRANCH ${GIT_BRANCH_FUNC} )

# same procedure for ufo-data
find_branch_name(REPO_DIR_NAME ufo)
if( NOT DEFINED ENV{LOCAL_PATH_JEDI_TESTFILES} AND NOT DEFINED ${GIT_TAG_FUNC} )
  ecbuild_bundle( PROJECT ufo-data GIT "https://github.com/JCSDA-internal/ufo-data.git" TAG 87702a24ac6349495e9182d5ee833b488fb1f2fb ) # develop on jan 28
endif()

# If UFO's current branch is available in ufo-data repo, that branch will be checked out
branch_checkout (REPO_DIR_NAME ufo-data
                 BRANCH ${GIT_BRANCH_FUNC} )

# same procedure for fv3-jedi-data
find_branch_name(REPO_DIR_NAME fv3-jedi)
if( NOT DEFINED ENV{LOCAL_PATH_JEDI_TESTFILES} AND NOT DEFINED ${GIT_TAG_FUNC} )
  ecbuild_bundle( PROJECT fv3-jedi-data GIT "https://github.com/JCSDA-internal/fv3-jedi-data.git" BRANCH feature/ufs_dom ) # updated from develop on jan 28
endif()

# If fv3-jedi's current branch is available in fv3-jedi-data repo, that branch will be checked out
branch_checkout (REPO_DIR_NAME fv3-jedi-data
                 BRANCH ${GIT_BRANCH_FUNC} )

# Build Doxygen documentation
# ---------------------------
option(BUILD_UFSJEDI_BUNDLE_DOC "Build documentation" OFF)
if(BUILD_UFSJEDI_BUNDLE_DOC)
   add_subdirectory( Documentation )
endif()

ecbuild_bundle_finalize()
