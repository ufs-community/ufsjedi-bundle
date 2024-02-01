# ufs-bundle

Bundle for interfacing UFS models with JEDI interfaces

## Required thirdparty libraries

This bundle requires the jedi-ufs-env meta-module from spack-stack version 1.5.1. Once loaded a module list command will show the following:
```
> module li

Currently Loaded Modules:

  1) intel-oneapi-compilers/2021.3.0  27) gettext/0.21      53) libtirpc/1.2.6               79) py-et-xmlfile/1.0.1
  2) stack-intel/2021.3.0             28) libunistring/1.1  54) hdf/4.2.15                   80) py-jdcal/1.3
  3) intel-oneapi-mpi/2021.3.0        29) libidn2/2.3.4     55) jedi-cmake/1.4.0             81) py-openpyxl/3.0.7
  4) stack-intel-oneapi-mpi/2021.3.0  30) pcre2/10.42       56) libxt/1.1.5                  82) py-six/1.16.0
  5) bacio/2.4.1                      31) git/2.40.0        57) libxmu/1.1.4                 83) py-python-dateutil/2.8.2
  6) snappy/1.1.10                    32) nccmp/1.9.0.1     58) libxpm/3.5.12                84) py-pytz/2023.3
  7) zlib/1.2.13                      33) py-pip/23.1.2     59) libxaw/1.0.13                85) py-pandas/1.5.3
  8) zstd/1.5.2                       34) wget/1.21.2       60) udunits/2.2.28               86) py-pybind11/2.8.1
  9) c-blosc/1.21.4                   35) base-env/1.0.0    61) ncview/2.1.8                 87) py-pycodestyle/2.8.0
 10) curl/8.1.2                       36) boost/1.78.0      62) netcdf-cxx4/4.3.1            88) py-pyhdf/0.10.4
 11) pkg-config/0.29.2                37) bufr/12.0.1       63) json/3.10.5                  89) libyaml/0.2.5
 12) hdf5/1.14.0                      38) ecbuild/3.7.2     64) json-schema-validator/2.1.0  90) py-pyyaml/5.4.1
 13) netcdf-c/4.9.2                   39) openjpeg/2.3.1    65) odc/1.4.6                    91) py-packaging/23.1
 14) netcdf-fortran/4.6.0             40) eccodes/2.27.0    66) py-attrs/21.4.0              92) py-xarray/2022.3.0
 15) parallel-netcdf/1.12.2           41) eigen/3.4.0       67) py-pycparser/2.21            93) jedi-base-env/1.0.0
 16) parallelio/2.5.10                42) openblas/0.3.19   68) py-cffi/1.15.1               94) gftl/1.10.0
 17) esmf/8.5.0                       43) eckit/1.24.4      69) py-findlibs/0.0.2            95) gftl-shared/1.6.1
 18) fms/2023.02.01                   44) fftw/3.3.10       70) py-setuptools/59.4.0         96) fargparse/1.5.0
 19) libjpeg/2.1.0                    45) fckit/0.11.0      71) py-numpy/1.22.3              97) mapl/2.40.3-esmf-8.5.0
 20) jasper/2.0.32                    46) fiat/1.2.0        72) py-eccodes/1.4.2             98) w3emc/2.10.0
 21) libpng/1.6.37                    47) ectrans/1.2.0     73) py-f90nml/1.4.3              99) nemsio/2.5.4
 22) g2/3.4.5                         48) atlas/0.35.0      74) py-h5py/3.7.0               100) sfcio/1.4.1
 23) g2tmpl/1.10.2                    49) git-lfs/3.0.2     75) py-cftime/1.0.3.4           101) sigio/2.3.2
 24) sp/2.3.3                         50) gsibec/1.1.3      76) py-netcdf4/1.5.8            102) w3nco/2.4.1
 25) ip/4.3.0                         51) gsl-lite/0.37.0   77) py-bottleneck/1.3.7         103) jedi-ufs-env/1.0.0
 26) cmake/3.23.1                     52) krb5/1.20.1       78) py-numexpr/2.8.4
```
On a pre-configured platform that has spack-stack-1.5.1 (or 1.5.0) installed, load the spack-stack modules as described in https://spack-stack.readthedocs.io/en/1.5.1 (https://spack-stack.readthedocs.io/en/1.5.0), followed by `module load jedi-ufs-env`. On a configurable (user) platform, follow the instructions in https://spack-stack.readthedocs.io/en/1.5.1 to build the `skylab-dev` or `unified-dev` environment, then run (use the appropriate path, compiler/mpi/python versions for your system):

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

The bundle can be built in four different configuragions: with fv3-jedi and the UFS configured for atmosphere-only, 
with soca and the UFS configured with a data-atmosphere using NG-GODAS, with fv3-jedi and soca and the UFS
configured with S2S coupling, or with fv3-jedi and the UFS configured for atmosphere+aerosols. Only the atmosphere-only configuration
has test cases, but all will build.

The parameter for specifying the configuration type is `-DAPP=[ATM|ATMAERO|NG-GODAS|S2S]` on the cmake configuration line. Create a build directory under/outside `ufs-bundle` and `cd` to it. Then run one of the following `cmake` commands:
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
If using a case-insensitive file system on OS X, the patch which is required to compile with SOCA will not work correctly. This problem
can be overcome by setting up a case-sensitive volume on the local system following the instructions found here--

https://brianboyko.medium.com/a-case-sensitive-src-folder-for-mac-programmers-176cc82a3830

Once a case-sensitive directory is established, clone the ufs-bundle there proceed with the configure and build as normal.
```

While building with soca (NG-GODAS or S2S), there will be a long pause during configuration when `cmake` is downloading the input files for the test to be run.

After configuration, run `make -j 8` to build.

The ctests for ATM all have `ufs_` in their names. To run the tests, run the following:
```
ctest -R ufs_ 2>&1 | tee log.ctest.ufs
Test project /Users/heinzell/work/ufs-bundle/20221114/build-debug-atm-20230121-with-ufs-import
Test project /home/mpotts/jedi/ufs-bundle/build-atm
    Start 1637: fv3jedi_setup_ufs_c48_data
f1/5 Test #1637: fv3jedi_setup_ufs_c48_data ..................   Passed   14.67 sec
    Start 1638: fv3jedi_setup_ufs_rundir_warmstart
2/5 Test #1638: fv3jedi_setup_ufs_rundir_warmstart ..........   Passed    0.75 sec
    Start 1639: fv3jedi_setup_ufs_rundir_warmstart_2
3/5 Test #1639: fv3jedi_setup_ufs_rundir_warmstart_2 ........   Passed    0.89 sec
    Start 1692: fv3jedi_test_tier1_model_ufs_warmstart
4/5 Test #1692: fv3jedi_test_tier1_model_ufs_warmstart ......   Passed  383.90 sec
    Start 1698: fv3jedi_test_tier1_forecast_ufs_warmstart
5/5 Test #1698: fv3jedi_test_tier1_forecast_ufs_warmstart ...   Passed  387.41 sec

100% tests passed, 0 tests failed out of 5
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
