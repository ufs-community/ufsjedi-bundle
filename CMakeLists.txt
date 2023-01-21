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

ecbuild_bundle( PROJECT eckit GIT "https://github.com/ecmwf/eckit.git" TAG 1.18.2 )
ecbuild_bundle( PROJECT fckit GIT "https://github.com/ecmwf/fckit.git" TAG 0.9.5 )
ecbuild_bundle( PROJECT atlas GIT "https://github.com/ecmwf/atlas.git" TAG 0.30.0 )

# External FMS
find_package(FMS 2022.04 REQUIRED COMPONENTS R4 R8)

if(UFS_APP MATCHES "^(S2S)$" OR UFS_APP MATCHES "^(NG-GODAS)$")
  ecbuild_bundle( PROJECT gsw GIT "https://github.com/jcsda-internal/GSW-Fortran.git" TAG 1a02ebaf6f7a4e9f2c2d2dd973fb050e697bcc74 )  # develop on nov 15
endif()

# Core JEDI repositories
# ----------------------
ecbuild_bundle( PROJECT oops  GIT "https://github.com/jcsda-internal/oops.git"  TAG c308945cbc6db4d6add0dac3581bbc4d457e8785 )  # develop on nov 15
ecbuild_bundle( PROJECT vader GIT "https://github.com/jcsda-internal/vader.git" TAG 3363fe28ba65a61227ec1d64504d2641730f51a4 )  # develop on nov 15
ecbuild_bundle( PROJECT saber GIT "https://github.com/jcsda-internal/saber.git" BRANCH bugfix/add_missing_netcdf_dependency_to_build_system )  # updated from develop on nov 15
ecbuild_bundle( PROJECT ioda  GIT "https://github.com/jcsda-internal/ioda.git"  TAG 876e7874fc917376500822157cda82c15ede02f8 )  # develop on nov 15
ecbuild_bundle( PROJECT ufo   GIT "https://github.com/jcsda-internal/ufo.git"   TAG f95dd253a850debd1f1b391ec63a47f99c341efa )  # develop on nov 15

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
ecbuild_bundle( PROJECT fv3-jedi-lm GIT "https://github.com/jcsda-internal/fv3-jedi-linearmodel.git" BRANCH feature/ufs_dom )  # updated from develop on nov 22

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
  ecbuild_bundle( PROJECT fv3-jedi GIT "https://github.com/jcsda-internal/fv3-jedi.git" BRANCH feature/ufs_dom )  # updated from develop on nov 15
  ecbuild_bundle( PROJECT soca     GIT "https://github.com/jcsda-internal/soca.git"     BRANCH feature/ufs_dom )  # was NOT updated on nov 15th
  add_dependencies(soca ufs-weather-model)
elseif(UFS_APP MATCHES "^(NG-GODAS)$")
  ecbuild_bundle( PROJECT soca     GIT "https://github.com/jcsda-internal/soca.git" BRANCH feature/ufs_dom )  # was NOT updated on nov 15th
  add_dependencies(soca ufs-weather-model)
elseif(UFS_APP MATCHES "^(ATM)$")
  ecbuild_bundle( PROJECT femps    GIT "https://github.com/jcsda-internal/femps.git"    TAG 1.2.0 )
  ecbuild_bundle( PROJECT fv3-jedi GIT "https://github.com/jcsda-internal/fv3-jedi.git" BRANCH feature/ufs_dom )  # updated from develop on nov 15
else()
  message(FATAL_ERROR "ufs-bundle unknown UFS_APP ${UFS_APP}")
endif()


# ioda, ufo, fv3-jedi and saber test data
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
  ecbuild_bundle( PROJECT ioda-data GIT "https://github.com/JCSDA-internal/ioda-data.git" TAG 2d9fb746b26a306711800960f471cb2ddc56c15c )  # develop on nov 22
endif()

# If IODA's current branch is available in ioda-data repo, that branch will be checked out
branch_checkout (REPO_DIR_NAME ioda-data
                 BRANCH ${GIT_BRANCH_FUNC} )

# same procedure for ufo-data
find_branch_name(REPO_DIR_NAME ufo)
if( NOT DEFINED ENV{LOCAL_PATH_JEDI_TESTFILES} AND NOT DEFINED ${GIT_TAG_FUNC} )
  ecbuild_bundle( PROJECT ufo-data GIT "https://github.com/JCSDA-internal/ufo-data.git" TAG 998ac3b375248b850ca38ea05749b37a411dac4d )  # develop on nov 15
endif()

# If UFO's current branch is available in ufo-data repo, that branch will be checked out
branch_checkout (REPO_DIR_NAME ufo-data
                 BRANCH ${GIT_BRANCH_FUNC} )

# same procedure for fv3-jedi-data
find_branch_name(REPO_DIR_NAME fv3-jedi)
if( NOT DEFINED ENV{LOCAL_PATH_JEDI_TESTFILES} AND NOT DEFINED ${GIT_TAG_FUNC} )
  ecbuild_bundle( PROJECT fv3-jedi-data GIT "https://github.com/JCSDA-internal/fv3-jedi-data.git" BRANCH feature/ufs_dom )  # updated from develop on nov 15
endif()

# If fv3-jedi's current branch is available in fv3-jedi-data repo, that branch will be checked out
branch_checkout (REPO_DIR_NAME fv3-jedi-data
                 BRANCH ${GIT_BRANCH_FUNC} )

# same procedure for saber-data
find_branch_name(REPO_DIR_NAME saber)
if( NOT DEFINED ENV{LOCAL_PATH_JEDI_TESTFILES} AND NOT DEFINED ${GIT_TAG_FUNC} )
  ecbuild_bundle( PROJECT saber-data GIT "https://github.com/JCSDA-internal/saber-data.git" TAG 16da933fe4434f73fa51c000db787061d25dcedf )  # develop on nov 15
endif()

# If saber's current branch is available in saber-data repo, that branch will be checked out
branch_checkout (REPO_DIR_NAME saber-data
                 BRANCH ${GIT_BRANCH_FUNC} )

# Build Doxygen documentation
# ---------------------------
option(BUILD_UFSJEDI_BUNDLE_DOC "Build documentation" OFF)
if(BUILD_UFSJEDI_BUNDLE_DOC)
   add_subdirectory( Documentation )
endif()

ecbuild_bundle_finalize()
