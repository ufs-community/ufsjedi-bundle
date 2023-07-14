# (C) Copyright 2021-2021 NOAA

# ##########
# ufs-bundle
# ##########

cmake_minimum_required( VERSION 3.12 FATAL_ERROR )

find_package( ecbuild 3.5 REQUIRED HINTS ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/../ecbuild)

project( ufs-bundle VERSION 1.1.0 LANGUAGES C CXX Fortran )

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include( ecbuild_bundle )
include( GNUInstallDirs )
set(CMAKE_INSTALL_LIBDIR "lib")

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
# ecbuild_bundle( PROJECT eckit GIT "https://github.com/ecmwf/eckit.git" TAG 1.20.2 )
# ecbuild_bundle( PROJECT fckit GIT "https://github.com/ecmwf/fckit.git" TAG 0.10.0 )
# ecbuild_bundle( PROJECT atlas GIT "https://github.com/ecmwf/atlas.git" TAG 0.32.1 )

# External FMS
find_package(FMS 2022.04 REQUIRED COMPONENTS R4 R8)

# Core JEDI repositories
# ----------------------
ecbuild_bundle( PROJECT oops  GIT "https://github.com/jcsda-internal/oops.git"  BRANCH develop UPDATE )
ecbuild_bundle( PROJECT vader GIT "https://github.com/jcsda-internal/vader.git" BRANCH develop UPDATE )
ecbuild_bundle( PROJECT saber GIT "https://github.com/jcsda-internal/saber.git" BRANCH develop UPDATE )


if(UFS_APP MATCHES "^(ATMAERO)$" OR UFS_APP MATCHES "^(S2S)$" OR UFS_APP MATCHES "^(NG-GODAS)$")
  ecbuild_bundle( PROJECT gsw GIT "https://github.com/jcsda-internal/GSW-Fortran.git" BRANCH develop UPDATE )
endif()

ecbuild_bundle( PROJECT crtm  GIT "https://github.com/jcsda-internal/crtm.git"  TAG v2.4.1-jedi )

ecbuild_bundle( PROJECT ioda  GIT "https://github.com/jcsda-internal/ioda.git" BRANCH develop UPDATE )
ecbuild_bundle( PROJECT ufo   GIT "https://github.com/jcsda-internal/ufo.git" BRANCH develop UPDATE )

# Options for building with certain models
# ----------------------------------------
set(UFS_APP "ATM" CACHE STRING "Choose the UFS Application")
set_property(CACHE UFS_APP PROPERTY STRINGS "ATM" "ATMAERO" "NG-GODAS" "S2S")
if(NOT UFS_APP MATCHES "^(ATM|ATMAERO|NG-GODAS|S2S)$")
  ecbuild_error("Valid options for -DUFS_APP are ATM|ATMAERO|NG-GODAS|S2S")
endif()
ecbuild_info("Building with UFS application: ${UFS_APP}")
set(FV3_FORECAST_MODEL "UFS")

# fv3-jedi linear model
# ---------------------
ecbuild_bundle( PROJECT fv3-jedi-lm GIT "https://github.com/jcsda-internal/fv3-jedi-linearmodel.git" BRANCH feature/ufs_dom )  # updated from develop on nov 22, develop hasn't changed by june 13

message(INFO "CMAKE_INSTALL_LIBDIR: ${CMAKE_INSTALL_LIBDIR}")
include_directories(${DEPEND_LIB_ROOT}/${CMAKE_INSTALL_INCLUDEDIR})
include_directories(${DEPEND_LIB_ROOT}/include_r8)
link_directories(${DEPEND_LIB_ROOT}/${CMAKE_INSTALL_LIBDIR})

include( ExternalProject )

# Needed to get correct OpenMP link libraries on macOS
set(UFS_CMAKE_EXE_LINKER_FLAGS "-L${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}")
find_package(OpenMP REQUIRED)
if(APPLE)
  set(UFS_CMAKE_EXE_LINKER_FLAGS "${UFS_CMAKE_EXE_LINKER_FLAGS} ${OpenMP_libomp_LIBRARY} ${OpenMP_libomp_LIBRARY}")
endif()
message (STATUS "UFS_CMAKE_EXE_LINKER_FLAGS: ${UFS_CMAKE_EXE_LINKER_FLAGS}")

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(UFS_CMAKE_BUILD_TYPE_FLAG "-DDEBUG=ON")
else()
  # MAYBE THIS SHOULD BE EMPTY SO THAT RELEASE IS USED, REPRO ISN'T REALLY SUPPORTED ANYMORE
  set(UFS_CMAKE_BUILD_TYPE_FLAG "-DREPRO=ON")
endif()

ExternalProject_Add(ufs-weather-model
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/ufs-weather-model
  GIT_REPOSITORY https://github.com/climbfuji/ufs-weather-model
  GIT_SUBMODULES_RECURSE TRUE
  GIT_TAG feature/consolidate_dom_update_20221114  # updated from develop on Mar 6
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ufs-weather-model
  UPDATE_DISCONNECTED ON
  INSTALL_DIR ${DEPEND_LIB_ROOT}
  # DH* 20230316 turn off OpenMP for now ...
  CMAKE_ARGS -DCMAKE_INSTALL_LIBDIR=${CMAKE_INSTALL_LIBDIR} -DCMAKE_C_FLAGS=-fPIC -DCMAKE_Fortran_FLAGS=-fPIC -DCMAKE_CXX_FLAGS=-fPIC -DCCPP_SUITES=FV3_GFS_v16,FV3_GFS_v16_coupled,FV3_GFS_v15p2 -DCMAKE_EXE_LINKER_FLAGS=${UFS_CMAKE_EXE_LINKER_FLAGS} -DCMAKE_C_COMPILER=${MPI_C_COMPILER} -DCMAKE_CXX_COMPILER=${MPI_CXX_COMPILER} -DCMAKE_Fortran_COMPILER=${MPI_Fortran_COMPILER} -DJEDI_DRIVER=ON -DCMAKE_PREFIX_PATH=${CMAKE_CURRENT_BINARY_DIR}/gsw ${UFS_CMAKE_BUILD_TYPE_FLAG} -DOPENMP=OFF -DINLINE_POST=OFF -DMULTI_GASES=OFF -DMPI=ON -DAPP=${UFS_APP} -DCMAKE_INSTALL_PREFIX=${DEPEND_LIB_ROOT}
  # *DH
  INSTALL_COMMAND make install
  BUILD_ALWAYS TRUE
  )

if(UFS_APP MATCHES "^(ATMAERO)$" OR UFS_APP MATCHES "^(S2S)$" OR UFS_APP MATCHES "^(NG-GODAS)$")
  add_dependencies(ufs-weather-model gsw)
endif()
add_library( ufs IMPORTED STATIC)
add_library( ufs_aerosols IMPORTED STATIC)
add_library( aerosols_gridcomp IMPORTED STATIC)
add_library( gocart_gridcomp IMPORTED STATIC)
add_library( ca2g_gridcomp IMPORTED STATIC)
add_library( chem_shared IMPORTED STATIC)
add_library( gocart_process IMPORTED STATIC)
add_library( du2g_gridcomp IMPORTED STATIC)
add_library( ni2g_gridcomp IMPORTED STATIC)
add_library( ss2g_gridcomp IMPORTED STATIC)
add_library( su2g_gridcomp IMPORTED STATIC)
add_library( ga_environment IMPORTED STATIC)
add_library( cdeps IMPORTED STATIC)
add_library( cmeps IMPORTED STATIC)
add_library( ccpp IMPORTED STATIC)
add_library( stochastic_physics IMPORTED STATIC)
add_library( fv3atm IMPORTED STATIC)
add_library( ccppphys IMPORTED STATIC)
add_library( mom6 IMPORTED STATIC)
set_target_properties( ufs PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/${CMAKE_INSTALL_LIBDIR}/libufs.a)
set_target_properties( ufs_aerosols PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/${CMAKE_INSTALL_LIBDIR}/libUFS_Aerosols.a)
set_target_properties( aerosols_gridcomp PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/${CMAKE_INSTALL_LIBDIR}/libAerosol_GridComp.a)
set_target_properties( gocart_gridcomp PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/${CMAKE_INSTALL_LIBDIR}/libGOCART2G_GridComp.a)
set_target_properties( ca2g_gridcomp PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/${CMAKE_INSTALL_LIBDIR}/libCA2G_GridComp.a)
set_target_properties( chem_shared PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/${CMAKE_INSTALL_LIBDIR}/libChem_Shared2G.a)
set_target_properties( gocart_process PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/${CMAKE_INSTALL_LIBDIR}/libProcess_Library.a)
set_target_properties( du2g_gridcomp PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/${CMAKE_INSTALL_LIBDIR}/libDU2G_GridComp.a)
set_target_properties( ni2g_gridcomp PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/${CMAKE_INSTALL_LIBDIR}/libNI2G_GridComp.a)
set_target_properties( ss2g_gridcomp PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/${CMAKE_INSTALL_LIBDIR}/libSS2G_GridComp.a)
set_target_properties( su2g_gridcomp PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/${CMAKE_INSTALL_LIBDIR}/libSU2G_GridComp.a)
set_target_properties( ga_environment PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/${CMAKE_INSTALL_LIBDIR}/libGA_Environment.a)
set_target_properties( cdeps PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/${CMAKE_INSTALL_LIBDIR}/libcdeps.a)
set_target_properties( cmeps PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/${CMAKE_INSTALL_LIBDIR}/libcmeps.a)
set_target_properties(ccpp PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/${CMAKE_INSTALL_LIBDIR}/libccpp_framework.a)
set_target_properties(stochastic_physics PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/${CMAKE_INSTALL_LIBDIR}/libstochastic_physics.a)
set_target_properties(fv3atm PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/${CMAKE_INSTALL_LIBDIR}/libfv3atm.a)
set_target_properties(ccppphys PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/${CMAKE_INSTALL_LIBDIR}/libccpp_physics.a)
set_target_properties(mom6 PROPERTIES IMPORTED_LOCATION ${DEPEND_LIB_ROOT}/${CMAKE_INSTALL_LIBDIR}/libmom6.a)

if(UFS_APP MATCHES "^(S2S)$")
  # fv3-jedi and associated repositories
  # ------------------------------------
  ecbuild_bundle( PROJECT femps    GIT "https://github.com/jcsda-internal/femps.git"    TAG 1.2.0 )
  ecbuild_bundle( PROJECT fv3-jedi GIT "https://github.com/jcsda-internal/fv3-jedi.git" BRANCH feature/ufs_dom )
  ecbuild_bundle( PROJECT soca     GIT "https://github.com/jcsda-internal/soca.git"     BRANCH feature/dev_june_13 )
  add_dependencies(soca ufs-weather-model)
elseif(UFS_APP MATCHES "^(NG-GODAS)$")
  ecbuild_bundle( PROJECT soca     GIT "https://github.com/jcsda-internal/soca.git" BRANCH feature/dev_june_13 ) 
  add_dependencies(soca ufs-weather-model)
elseif(UFS_APP MATCHES "^(ATM)$" OR UFS_APP MATCHES "^(ATMAERO)$")
  ecbuild_bundle( PROJECT femps    GIT "https://github.com/jcsda-internal/femps.git"    TAG 1.2.0 )
  ecbuild_bundle( PROJECT fv3-jedi GIT "https://github.com/jcsda-internal/fv3-jedi.git" BRANCH feature/ufs_dom )
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
  ecbuild_bundle( PROJECT ioda-data GIT "https://github.com/JCSDA-internal/ioda-data.git" BRANCH develop UPDATE )
endif()

# If IODA's current branch is available in ioda-data repo, that branch will be checked out
branch_checkout (REPO_DIR_NAME ioda-data
                 BRANCH ${GIT_BRANCH_FUNC} )

# same procedure for ufo-data
find_branch_name(REPO_DIR_NAME ufo)
if( NOT DEFINED ENV{LOCAL_PATH_JEDI_TESTFILES} AND NOT DEFINED ${GIT_TAG_FUNC} )
  ecbuild_bundle( PROJECT ufo-data GIT "https://github.com/JCSDA-internal/ufo-data.git" BRANCH develop UPDATE )
endif()

# If UFO's current branch is available in ufo-data repo, that branch will be checked out
branch_checkout (REPO_DIR_NAME ufo-data
                 BRANCH ${GIT_BRANCH_FUNC} )

# same procedure for fv3-jedi-data
find_branch_name(REPO_DIR_NAME fv3-jedi)
if( NOT DEFINED ENV{LOCAL_PATH_JEDI_TESTFILES} AND NOT DEFINED ${GIT_TAG_FUNC} )
  ecbuild_bundle( PROJECT fv3-jedi-data GIT "https://github.com/JCSDA-internal/fv3-jedi-data.git" BRANCH feature/ufs_dom )
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
