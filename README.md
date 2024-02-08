# ufs-bundle

Bundle for interfacing UFS models with JEDI interfaces

## Required thirdparty libraries

This bundle requires loading the `jedi-ufs-env` and after that the `fms/2023.02.01` modules of spack-stack-1.5.1, or any equivalent installation providing the following modules:
```
> module li

Currently Loaded Modules:
  1) stack-apple-clang/13.1.6  15) snappy/1.1.10           29) libpng/1.6.37            43) ecbuild/3.7.2    57) hdf/4.2.15                   71) py-cffi/1.15.1        85) py-six/1.16.0             99) gftl-shared/1.6.1
  2) pmix/4.2.3                16) c-blosc/1.21.4          30) g2/3.4.5                 44) openjpeg/2.3.1   58) jedi-cmake/1.4.0             72) py-findlibs/0.0.2     86) py-python-dateutil/2.8.2 100) fargparse/1.5.0
  3) zlib/1.2.13               17) curl/8.1.2              31) g2tmpl/1.10.2            45) eccodes/2.27.0   59) libxt/1.1.5                  73) py-setuptools/59.4.0  87) py-pytz/2023.3           101) mapl/2.40.3-esmf-8.5.0
  4) openmpi/4.1.5             18) pkg-config/0.29.2       32) sp/2.3.3                 46) eigen/3.4.0      60) libxmu/1.1.4                 74) py-numpy/1.22.3       88) py-pandas/1.5.3          102) w3emc/2.10.0
  5) stack-openmpi/4.1.5       19) hdf5/1.14.0             33) ip/4.3.0                 47) openblas/0.3.19  61) libxpm/3.5.12                75) py-eccodes/1.4.2      89) py-pybind11/2.8.1        103) nemsio/2.5.4
  6) pigz/2.7                  20) netcdf-c/4.9.2          34) cmake/3.27.0             48) eckit/1.24.4     62) libxaw/1.0.13                76) py-f90nml/1.4.3       90) py-pycodestyle/2.8.0     104) sfcio/1.4.1
  7) zstd/1.5.2                21) netcdf-fortran/4.6.0    35) git/2.32.0               49) fftw/3.3.10      63) udunits/2.2.28               77) py-h5py/3.7.0         91) py-pyhdf/0.10.4          105) sigio/2.3.2
  8) tar/1.34                  22) parallel-netcdf/1.12.2  36) libbacktrace/2020-02-19  50) fckit/0.11.0     64) ncview/2.1.8                 78) py-cftime/1.0.3.4     92) libyaml/0.2.5            106) w3nco/2.4.1
  9) gettext/0.21.1            23) parallelio/2.5.10       37) nccmp/1.9.0.1            51) fiat/1.2.0       65) netcdf-cxx4/4.3.1            79) py-netcdf4/1.5.8      93) py-pyyaml/5.4.1          107) jedi-ufs-env/1.0.0
 10) libxcrypt/4.4.35          24) esmf/8.5.0              38) py-pip/23.1.2            52) ectrans/1.2.0    66) json/3.10.5                  80) py-bottleneck/1.3.7   94) py-scipy/1.9.3
 11) sqlite/3.42.0             25) llvm-openmp/16.0.0      39) wget/1.21.2              53) atlas/0.35.0     67) json-schema-validator/2.1.0  81) py-numexpr/2.8.4      95) py-packaging/23.1
 12) python/3.10.8             26) fms/2023.02.01          40) base-env/1.0.0           54) git-lfs/3.3.0    68) odc/1.4.6                    82) py-et-xmlfile/1.0.1   96) py-xarray/2022.3.0
 13) stack-python/3.10.8       27) libjpeg/2.1.0           41) boost/1.78.0             55) gsibec/1.1.3     69) py-attrs/21.4.0              83) py-jdcal/1.3          97) jedi-base-env/1.0.0
 14) bacio/2.4.1               28) jasper/2.0.32           42) bufr/12.0.1              56) gsl-lite/0.37.0  70) py-pycparser/2.21            84) py-openpyxl/3.0.7     98) gftl/1.10.0
```
On a pre-configured platform that has spack-stack-1.5.1 installed, load the spack-stack modules as described in https://spack-stack.readthedocs.io/en/1.5.1, followed by `module load jedi-ufs-env`. On a configurable (user) platform, follow the instructions in https://spack-stack.readthedocs.io/en/1.5.1 to build the `skylab-dev` or `unified-dev` environment, then run (use the appropriate path, compiler/mpi/python versions for your system):
```
module use /Users/heinzell/prod/spack-stack-1.5.1/envs/unified-dev/install/modulefiles/Core
module load stack-apple-clang/13.1.6
module load stack-openmpi/4.1.5
module load stack-python/3.10.8
module load jedi-ufs-env/unified-dev
module load fms/2023.02.01
```

## Building ufs-bundle

The bundle can be built in three different configuragions: with fv3-jedi and the UFS configured for atmosphere-only, 
with soca and the UFS configured with a data-atmosphere using NG-GODAS, or with fv3-jedi and soca and the UFS
configured with S2S coupling. Only the first two configurations have test cases and are known to work, but all will build.

The parameter for specifying the configuration type is `-DAPP=[ATM|NG-GODAS|S2S]` on the cmake configuration line. Create a build directory under/outside `ufs-bundle` and `cd` to it. Then run one of the following `cmake` commands:
```
cmake -DCMAKE_BUILD_TYPE=Debug -DUFS_APP=ATM .. 2>&1 | tee log.cmake
cmake -DCMAKE_BUILD_TYPE=Debug -DUFS_APP=ATMAERO .. 2>&1 | tee log.cmake
cmake -DCMAKE_BUILD_TYPE=Debug -DUFS_APP=NG-GODAS .. 2>&1 | tee log.cmake
cmake -DCMAKE_BUILD_TYPE=Debug -DUFS_APP=S2S .. 2>&1 | tee log.cmake
```
When using the native Apple `clang` compiler on macOS with `llvm-openmp` installed via homebrew or spack, it may be necessary to add `-DCMAKE_SHARED_LINKER_FLAGS="${llvm_openmp_ROOT}/lib/libomp.dylib"` to the `cmake` command. We have identified this beig an issue with FMS not declaring its OpenMP dependencies correctly. A bug fix was merged for FMS recently, once the next tag finds its way into spack-stack this will no longer be needed.

While building with soca (NG-GODAS or S2S), there will be a long pause during configuration when `cmake` is downloading the input files for the test to be run.

After configuration, run `make -j 8` to build.

The ctests for ATM all have `_ufs` in their names. After running `ctest -R get_`, run the following:

# DH 20240708 - NOTE: EVERYTHING BELOW IS OUTDATED - UPDATE ONCE UFS TESTS ARE FIXED ON MACOS (WIP)
```
ctest -R _ufs 2>&1 | tee log.ctest.ufs
Test project /Users/heinzell/work/ufs-bundle/20221114/build-debug-atm-20230121-with-ufs-import
    Start 1061: fv3jedi_setup_ufs_rundir_warmstart
1/6 Test #1061: fv3jedi_setup_ufs_rundir_warmstart ..........   Passed    0.10 sec
    Start 1062: fv3jedi_setup_ufs_rundir_coldstart
2/6 Test #1062: fv3jedi_setup_ufs_rundir_coldstart ..........   Passed    0.09 sec
    Start 1108: fv3jedi_test_tier1_model_ufs_warmstart
3/6 Test #1108: fv3jedi_test_tier1_model_ufs_warmstart ......   Passed   25.49 sec
    Start 1109: fv3jedi_test_tier1_model_ufs_coldstart
4/6 Test #1109: fv3jedi_test_tier1_model_ufs_coldstart ......***Failed    7.82 sec
    Start 1113: fv3jedi_test_tier1_forecast_ufs_warmstart
5/6 Test #1113: fv3jedi_test_tier1_forecast_ufs_warmstart ...   Passed   25.04 sec
    Start 1114: fv3jedi_test_tier1_forecast_ufs_coldstart
6/6 Test #1114: fv3jedi_test_tier1_forecast_ufs_coldstart ...***Failed    4.02 sec

67% tests passed, 2 tests failed out of 6
```

The ctest for NG-GODAS is called `test_soca_forecast_ufs`. Note that there is no test to download the data, this is currently hardcoded in the `soca` top-level `CMakeLists.txt` file.
```
ctest -R _ufs 2>&1 | tee log.ctest.ufs
Test project /Users/heinzell/work/ufs-bundle/20221114/build-debug-ng-godas
    Start 1094: test_soca_forecast_ufs
1/1 Test #1094: test_soca_forecast_ufs ...........***Failed   11.51 sec

0% tests passed, 1 tests failed out of 1

Label Time Summary:
mpi       =  11.51 sec*proc (1 test)
script    =  11.51 sec*proc (1 test)
soca      =  11.51 sec*proc (1 test)

Total Test time (real) =  13.28 sec

The following tests FAILED:
	1094 - test_soca_forecast_ufs (Failed)
Errors while running CTest
```

At this point, there are no ctests for ATMAERO or S2S.

Note for later for running on Hera: need to add `-DMPIEXEC_EXECUTABLE="/apps/slurm/default/bin/srun" -DMPIEXEC_NUMPROC_FLAG="-n"` to `cmake` command, then run `ctest -R get_` on login node, then acquire a compute node, for example via `salloc -N 1 -n 24 --time=480 --qos=batch -A da-cpu -I`, then run the actual `ctests` on the compute node.
