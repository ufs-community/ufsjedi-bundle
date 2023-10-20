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
include( $ENV{jedi_cmake_ROOT}/share/jedicmake/Functions/git_functions.cmake )

# ECMWF libs
# ----------
# ecbuild_bundle( PROJECT eckit GIT "https://github.com/ecmwf/eckit.git" TAG 1.23.0 )
# ecbuild_bundle( PROJECT fckit GIT "https://github.com/ecmwf/fckit.git" TAG 0.10.1 )
# ecbuild_bundle( PROJECT atlas GIT "https://github.com/ecmwf/atlas.git" TAG 0.33.0 )

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

ecbuild_bundle( PROJECT crtm GIT "https://github.com/JCSDA/CRTMv3.git" BRANCH develop UPDATE )

option(ENABLE_IODA_DATA "Obtain ioda test data from ioda-data repository (vs tarball)" ON)
ecbuild_bundle( PROJECT ioda-data GIT "https://github.com/JCSDA-internal/ioda-data.git" BRANCH develop UPDATE )
ecbuild_bundle( PROJECT ioda      GIT "https://github.com/jcsda-internal/ioda.git"      BRANCH develop UPDATE )

option(ENABLE_UFO_DATA "Obtain ufo test data from ufo-data repository (vs tarball)" ON)
ecbuild_bundle( PROJECT ufo-data GIT "https://github.com/jcsda-internal/ufo-data.git" BRANCH develop UPDATE )
ecbuild_bundle( PROJECT ufo      GIT "https://github.com/jcsda-internal/ufo.git"      BRANCH develop UPDATE )

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
ecbuild_bundle( PROJECT fv3-jedi-lm GIT "https://github.com/jcsda-internal/fv3-jedi-linearmodel.git" BRANCH feature/ufs_dom UPDATE )  # updated from develop Aug 30 2023
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
  GIT_TAG feature/consolidate_dom_update_20221114  # updated from develop on 2023/07/17
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ufs-weather-model
  UPDATE_DISCONNECTED ON
  INSTALL_DIR ${DEPEND_LIB_ROOT}
  # DH* 20230316 turn off OpenMP for now ...
  CMAKE_ARGS -DCMAKE_INSTALL_LIBDIR=${CMAKE_INSTALL_LIBDIR} -DCMAKE_C_FLAGS=-fPIC -DCMAKE_Fortran_FLAGS=-fPIC -DCMAKE_CXX_FLAGS=-fPIC -DCCPP_SUITES=FV3_GFS_v16,FV3_GFS_v17_coupled_p8,FV3_GFS_v15p2 -DCMAKE_EXE_LINKER_FLAGS=${UFS_CMAKE_EXE_LINKER_FLAGS} -DCMAKE_C_COMPILER=${MPI_C_COMPILER} -DCMAKE_CXX_COMPILER=${MPI_CXX_COMPILER} -DCMAKE_Fortran_COMPILER=${MPI_Fortran_COMPILER} -DJEDI_DRIVER=ON -DCMAKE_PREFIX_PATH=${CMAKE_CURRENT_BINARY_DIR}/gsw ${UFS_CMAKE_BUILD_TYPE_FLAG} -DOPENMP=OFF -DINLINE_POST=OFF -DMULTI_GASES=OFF -DMPI=ON -DAPP=${UFS_APP} -DCMAKE_INSTALL_PREFIX=${DEPEND_LIB_ROOT}
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

if(UFS_APP MATCHES "^(ATM)$" OR UFS_APP MATCHES "^(ATMAERO)$" OR UFS_APP MATCHES "^(S2S)$")
  ecbuild_bundle( PROJECT femps         GIT "https://github.com/jcsda-internal/femps.git"         TAG 1.2.0 )
  option(ENABLE_FV3_JEDI_DATA "Obtain fv3-jedi test data from fv3-jedi-data repository (vs tarball)" ON)
  ecbuild_bundle( PROJECT fv3-jedi-data GIT "https://github.com/JCSDA-internal/fv3-jedi-data.git" BRANCH feature/ufs_dom_update_from_dev_20231020 UPDATE ) # updated from develop Oct 20 2023
  ecbuild_bundle( PROJECT fv3-jedi      GIT "https://github.com/jcsda-internal/fv3-jedi.git"      BRANCH feature/ufs_dom_update_from_dev_20231020 UPDATE )  # updated from develop Oct 20 2023
  if(UFS_APP MATCHES "^(S2S)$")
    ecbuild_bundle( PROJECT soca        GIT "https://github.com/jcsda-internal/soca.git"          BRANCH feature/ufs_dom UPDATE )  # note this has not been updated in a while, there are many merge conflicts that need to be resolved
    add_dependencies(soca ufs-weather-model)
  endif()
elseif(UFS_APP MATCHES "^(NG-GODAS)$")
  ecbuild_bundle( PROJECT soca     GIT "https://github.com/jcsda-internal/soca.git" BRANCH feature/ufs_dom UPDATE )  # note this has not been updated in a while, there are many merge conflicts that need to be resolved
  add_dependencies(soca ufs-weather-model)
else()
  message(FATAL_ERROR "ufs-bundle unknown UFS_APP ${UFS_APP}")
endif()

# Build Doxygen documentation
# ---------------------------
option(BUILD_UFSJEDI_BUNDLE_DOC "Build documentation" OFF)
if(BUILD_UFSJEDI_BUNDLE_DOC)
   add_subdirectory( Documentation )
endif()

ecbuild_bundle_finalize()
