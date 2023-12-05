# ufs-bundle

Bundle for interfacing UFS models with JEDI interfaces

## Required thirdparty libraries

This bundle requires the following spack-stack modules be loaded (all except `fms@2022.04` and `atlast@0.35.1` are in the `skylab-3.0.0` environment):
```
> module li

Currently Loaded Modules:
  1) stack-apple-clang/13.1.6  22) esmf/8.4.2               43) eccodes/2.27.0     64) json-schema-validator/2.1.0  85) py-pycodestyle/2.8.0
  2) pmix/4.2.3                23) llvm-openmp/16.0.0       44) eigen/3.4.0        65) odc/1.4.6                    86) py-pyhdf/0.10.4
  3) zlib/1.2.13               24) libjpeg/2.1.0            45) openblas/0.3.19    66) py-attrs/22.2.0              87) libyaml/0.2.5
  4) openmpi/4.1.5             25) jasper/2.0.32            46) eckit/1.23.1       67) py-pycparser/2.21            88) py-pyyaml/6.0
  5) stack-openmpi/4.1.5       26) libpng/1.6.37            47) fftw/3.3.10        68) py-cffi/1.15.1               89) py-gast/0.5.3
  6) pigz/2.7                  27) g2/3.4.5                 48) fckit/0.10.1       69) py-findlibs/0.0.2            90) py-beniget/0.4.1
  7) zstd/1.5.2                28) g2tmpl/1.10.2            49) fiat/1.1.0         70) py-setuptools/59.4.0         91) py-ply/3.11
  8) tar/1.34                  29) sp/2.3.3                 50) ectrans/1.2.0      71) py-numpy/1.22.3              92) py-pythran/0.12.2
  9) gettext/0.21.1            30) ip/3.3.3                 51) atlas/0.35.1       72) py-eccodes/1.4.2             93) py-scipy/1.9.3
 10) libxcrypt/4.4.33          31) cmake/3.23.1             52) gsibec/1.1.2       73) py-f90nml/1.4.3              94) py-xarray/2022.3.0
 11) sqlite/3.40.1             32) git/2.36.0               53) gsl-lite/0.37.0    74) py-h5py/3.7.0                95) jedi-base-env/1.0.0
 12) python/3.10.8             33) libbacktrace/2020-02-19  54) hdf/4.2.15         75) py-cftime/1.0.3.4            96) gftl/1.8.3
 13) stack-python/3.10.8       34) nccmp/1.9.0.1            55) jedi-cmake/1.4.0   76) py-netcdf4/1.5.3             97) gftl-shared/1.5.0
 14) bacio/2.4.1               35) py-pip/23.0              56) libxt/1.1.5        77) py-bottleneck/1.3.5          98) yafyaml/0.5.1
 15) curl/8.0.1                36) wget/1.21.3              57) libxmu/1.1.2       78) py-packaging/23.0            99) mapl/2.35.2-esmf-8.4.2
 16) pkg-config/0.29.2         37) base-env/1.0.0           58) libxpm/3.5.12      79) py-numexpr/2.8.3            100) w3nco/2.4.1
 17) hdf5/1.14.0               38) boost/1.78.0             59) libxaw/1.0.13      80) py-six/1.16.0               101) nemsio/2.5.2
 18) netcdf-c/4.9.2            39) bufr/12.0.0              60) udunits/2.2.28     81) py-python-dateutil/2.8.2    102) sigio/2.3.2
 19) netcdf-fortran/4.6.0      40) git-lfs/3.1.4            61) ncview/2.1.8       82) py-pytz/2022.2.1            103) w3emc/2.9.2
 20) parallel-netcdf/1.12.2    41) ecbuild/3.7.2            62) netcdf-cxx4/4.3.1  83) py-pandas/1.4.0             104) jedi-ufs-env/unified-dev
 21) parallelio/2.5.9          42) openjpeg/2.3.1           63) json/3.10.5        84) py-pybind11/2.8.1           105) fms@2023.01
```
On a pre-configured platform that has spack-stack-1.4.1 (or 1.4.0) installed, load the spack-stack modules as described in https://spack-stack.readthedocs.io/en/1.4.1 (https://spack-stack.readthedocs.io/en/1.4.0), followed by `module load jedi-ufs-env`. On a configurable (user) platform, follow the instructions in https://spack-stack.readthedocs.io/en/1.4.1 to build the `skylab-dev` or `unified-dev` environment, then run (use the appropriate path, compiler/mpi/python versions for your system):
```
module use /Users/heinzell/prod/spack-stack-v1/envs/unified-dev/install/modulefiles/Core
module load stack-apple-clang/13.1.6
module load stack-openmpi/4.1.5
module load stack-python/3.10.8
module load jedi-ufs-env/unified-dev
```
Further, for testing of the newest `fms@2023.02-beta1` tag, verify if the platform you are on has this version available and if yes, run
```
# Loading fms/2023.02-beta1 replaces the default fms@2023.01
module load fms/2023.02-beta1
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
When using the native Apple `clang` compiler on macOS with `llvm-openmp` installed via homebrew or spack, it may be necessary to add `-DCMAKE_SHARED_LINKER_FLAGS="${llvm_openmp_ROOT}/lib/libomp.dylib"` to the `cmake` command.

macOS users may also encounter this error during the linker phase:
```
dyld[47628]: dyld[47619]: Library not loaded: 'libpioc.dylib'
  Referenced from: '/Users/hLibrary not loaded: 'libpioc.dyleinzell/work/ufs-bundle/20230714ib'
...
```
This error comes from the `pioc` library not being installed correctly (a problem we have raised to the `parallelio` maintainers):
```
> otool -L ${parallelio_ROOT}/lib/libpioc.dylib
/Users/heinzell/prod/spack-stack-1.4.1/envs/unified-env/install/apple-clang/13.1.6/parallelio-2.5.9-r5txd2q/lib/libpioc.dylib:
	libpioc.dylib (compatibility version 0.0.0, current version 0.0.0)
	/Users/heinzell/prod/spack-stack-1.4.1/envs/unified-env/install/apple-clang/13.1.6/netcdf-c-4.9.2-vrrvi2u/lib/libnetcdf.19.dylib (compatibility version 22.0.0, current version 22.2.0)
	/Users/heinzell/prod/spack-stack-1.4.1/envs/unified-env/install/apple-clang/13.1.6/parallel-netcdf-1.12.2-mfx2uut/lib/libpnetcdf.4.dylib (compatibility version 5.0.0, current version 5.2.0)
	/Users/heinzell/prod/spack-stack-1.4.1/envs/unified-env/install/apple-clang/13.1.6/openmpi-4.1.5-j7pjg6h/lib/libmpi.40.dylib (compatibility version 71.0.0, current version 71.5.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1311.100.3)
```
The first identifier to the library itself must either contain `@rpath/` and the `RPATH` needs to be added correctly, or (easier) it must contain the full path to the library. This can be fixed by running:
```
install_name_tool -id ${parallelio_ROOT}/lib/libpioc.dylib ${parallelio_ROOT}/lib/libpioc.dylib
```
A similar fix may be needed for `libpiof.dylib`, depending the `UFS_APP`:
```
install_name_tool -id ${parallelio_ROOT}/lib/libpiof.dylib ${parallelio_ROOT}/lib/libpiof.dylib
install_name_tool -change libpioc.dylib ${parallelio_ROOT}/lib/libpioc.dylib ${parallelio_ROOT}/lib/libpiof.dylib
```

While building with soca (NG-GODAS or S2S), there will be a long pause during configuration when `cmake` is downloading the input files for the test to be run.

After configuration, run `make -j 8` to build.

The ctests for ATM all have `_ufs` in their names. After running `ctest -R get_`, run the following:
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
