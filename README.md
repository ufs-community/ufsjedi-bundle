# ufs-bundle

Bundle for interfacing UFS applications with JEDI interfaces

## Required thirdparty libraries

This bundle requires loading the `jedi-ufs-env` and after that the `fms/2023.02.01` and `awscli/1.27.84` modules of spack-stack-1.5.1, or any equivalent installation providing the following modules:
```
> module li

Currently Loaded Modules:
  1) stack-apple-clang/13.1.6  16) c-blosc/1.21.4          31) sp/2.3.3                 46) openblas/0.3.19   61) libxaw/1.0.13                76) py-h5py/3.7.0             91) libyaml/0.2.5          106) jedi-ufs-env/1.0.0
  2) pmix/4.2.3                17) curl/8.1.2              32) ip/4.3.0                 47) eckit/1.24.4      62) udunits/2.2.28               77) py-cftime/1.0.3.4         92) py-pyyaml/5.4.1        107) fms/2023.02.01
  3) zlib/1.2.13               18) pkg-config/0.29.2       33) cmake/3.27.0             48) fftw/3.3.10       63) ncview/2.1.8                 78) py-netcdf4/1.5.8          93) py-scipy/1.9.3         108) py-jmespath/1.0.1
  4) openmpi/4.1.5             19) hdf5/1.14.0             34) git/2.32.0               49) fckit/0.11.0      64) netcdf-cxx4/4.3.1            79) py-bottleneck/1.3.7       94) py-packaging/23.1      109) py-urllib3/1.26.12
  5) stack-openmpi/4.1.5       20) netcdf-c/4.9.2          35) libbacktrace/2020-02-19  50) fiat/1.2.0        65) json/3.10.5                  80) py-numexpr/2.8.4          95) py-xarray/2022.3.0     110) py-botocore/1.29.84
  6) pigz/2.7                  21) netcdf-fortran/4.6.0    36) nccmp/1.9.0.1            51) ectrans/1.2.0     66) json-schema-validator/2.1.0  81) py-et-xmlfile/1.0.1       96) jedi-base-env/1.0.0    111) py-colorama/0.4.4
  7) zstd/1.5.2                22) parallel-netcdf/1.12.2  37) py-pip/23.1.2            52) atlas/0.35.0      67) odc/1.4.6                    82) py-jdcal/1.3              97) gftl/1.10.0            112) py-docutils/0.16
  8) tar/1.34                  23) parallelio/2.5.10       38) wget/1.21.2              53) git-lfs/3.3.0     68) py-attrs/21.4.0              83) py-openpyxl/3.0.7         98) gftl-shared/1.6.1      113) py-pyasn1/0.4.8
  9) gettext/0.21.1            24) esmf/8.5.0              39) base-env/1.0.0           54) gsibec/1.1.3      69) py-pycparser/2.21            84) py-six/1.16.0             99) fargparse/1.5.0        114) py-rsa/4.7.2
 10) libxcrypt/4.4.35          25) llvm-openmp/16.0.0      40) boost/1.78.0             55) gsl-lite/0.37.0   70) py-cffi/1.15.1               85) py-python-dateutil/2.8.2 100) mapl/2.40.3-esmf-8.5.0 115) py-s3transfer/0.6.0
 11) sqlite/3.42.0             26) libjpeg/2.1.0           41) bufr/12.0.1              56) hdf/4.2.15        71) py-findlibs/0.0.2            86) py-pytz/2023.3           101) w3emc/2.10.0           116) awscli/1.27.84
 12) python/3.10.8             27) jasper/2.0.32           42) ecbuild/3.7.2            57) jedi-cmake/1.4.0  72) py-setuptools/59.4.0         87) py-pandas/1.5.3          102) nemsio/2.5.4
 13) stack-python/3.10.8       28) libpng/1.6.37           43) openjpeg/2.3.1           58) libxt/1.1.5       73) py-numpy/1.22.3              88) py-pybind11/2.8.1        103) sfcio/1.4.1
 14) bacio/2.4.1               29) g2/3.4.5                44) eccodes/2.27.0           59) libxmu/1.1.4      74) py-eccodes/1.4.2             89) py-pycodestyle/2.8.0     104) sigio/2.3.2
 15) snappy/1.1.10             30) g2tmpl/1.10.2           45) eigen/3.4.0              60) libxpm/3.5.12     75) py-f90nml/1.4.3              90) py-pyhdf/0.10.4          105) w3nco/2.4.1
```

On a pre-configured platform that has spack-stack-1.5.1 installed, load the spack-stack modules as described in https://spack-stack.readthedocs.io/en/1.5.1. On a configurable (user) platform, follow the instructions in https://spack-stack.readthedocs.io/en/1.5.1 to build the `skylab-dev` or `unified-dev` environment, then run (use the appropriate path, compiler/mpi/python versions for your system):
```
module use /Users/heinzell/prod/spack-stack-1.5.1/envs/unified-dev/install/modulefiles/Core
module load stack-apple-clang/13.1.6
module load stack-openmpi/4.1.5
module load stack-python/3.10.8
```

For pre-configured and configurable platforms, proceed with laoding the following modules
```
module load jedi-ufs-env
module load fms/2023.02.01
module load awscli/1.27.84
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

The ctests for the `UFS_APP=ATM` option all have `_ufs` in their names. After running `ctest -R get_`, run the following:
```
> ctest -R ufs_ 2>&1 | tee log.ctest.ufs
Test project /Users/heinzell/work-cs/ufs-bundle/ufs-bundle/build
    Start 1851: fv3jedi_setup_ufs_c48_data
1/5 Test #1851: fv3jedi_setup_ufs_c48_data ..................   Passed    6.29 sec
    Start 1852: fv3jedi_setup_ufs_rundir_warmstart
2/5 Test #1852: fv3jedi_setup_ufs_rundir_warmstart ..........   Passed    0.04 sec
    Start 1853: fv3jedi_setup_ufs_rundir_warmstart_2
3/5 Test #1853: fv3jedi_setup_ufs_rundir_warmstart_2 ........   Passed    0.02 sec
    Start 1906: fv3jedi_test_tier1_model_ufs_warmstart
4/5 Test #1906: fv3jedi_test_tier1_model_ufs_warmstart ......   Passed   33.57 sec
    Start 1912: fv3jedi_test_tier1_forecast_ufs_warmstart
5/5 Test #1912: fv3jedi_test_tier1_forecast_ufs_warmstart ...   Passed   47.34 sec

100% tests passed, 0 tests failed out of 5

Label Time Summary:
fv3-jedi    =  87.26 sec*proc (5 tests)
fv3jedi     =  87.26 sec*proc (5 tests)
mpi         =  80.92 sec*proc (2 tests)
script      =  87.26 sec*proc (5 tests)

Total Test time (real) =  90.37 sec
```

There are currently no ctests for the other `UFS_APP` build options (`ATMAERO`, `NG-GODAS`, `S2S`).

Depending on the platform, it may be necessary to add `-DMPIEXEC_EXECUTABLE="/path/to/srun" -DMPIEXEC_NUMPROC_FLAG="-n"` to `cmake` command and follow the usual instructions for running ctests for jedi-bundle on that system.
