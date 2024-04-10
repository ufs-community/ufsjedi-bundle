# ufs-bundle

Bundle for interfacing UFS applications with JEDI interfaces

## Required thirdparty libraries

This bundle requires loading the `jedi-ufs-env`, `sp/2.5.0` and `awscli-v2/2.13.22` modules of spack-stack-1.7.0, or any equivalent installation providing the following modules:
```
> module li

Currently Loaded Modules:
  1) stack-apple-clang/13.1.6  17) pkg-config/0.29.2       33) cmake/3.27.0             49) eigen/3.4.0       65) libxt/1.3.0                  81) py-h5py/3.8.0             97) py-pycodestyle/2.11.0  113) sigio/2.3.2
  2) pmix/5.0.1                18) hdf5/1.14.3             34) git/2.32.0               50) eckit/1.24.5      66) libxmu/1.1.4                 82) py-cftime/1.0.3.4         98) py-pyhdf/0.10.4        114) w3nco/2.4.1
  3) zlib-ng/2.1.5             19) netcdf-c/4.9.2          35) libbacktrace/2020-02-19  51) fftw/3.3.10       67) libxpm/3.5.17                83) py-netcdf4/1.5.8          99) libyaml/0.2.5          115) jedi-ufs-env/1.0.0
  4) openmpi/5.0.1             20) netcdf-fortran/4.6.1    36) nccmp/1.9.0.1            52) fckit/0.11.0      68) libxaw/1.0.15                84) py-bottleneck/1.3.7      100) py-pyyaml/6.0          116) py-awscrt/0.16.16
  5) stack-openmpi/5.0.1       21) parallel-netcdf/1.12.3  37) py-pip/23.1.2            53) fiat/1.2.0        69) udunits/2.2.28               85) py-numexpr/2.8.4         101) py-scipy/1.11.4        117) py-colorama/0.4.6
  6) gettext/0.21.1            22) parallelio/2.6.2        38) libc/1.0                 54) ectrans/1.2.0     70) ncview/2.1.9                 86) py-et-xmlfile/1.0.1      102) py-packaging/23.1      118) py-cryptography/38.0.1
  7) libxcrypt/4.4.35          23) esmf/8.6.0              39) wget/1.21.2              55) qhull/2020.2      71) netcdf-cxx4/4.3.1            87) py-openpyxl/3.1.2        103) py-xarray/2023.7.0     119) py-distro/1.8.0
  8) sqlite/3.43.2             24) llvm-openmp/16.0.0      40) base-env/1.0.0           56) atlas/0.36.0      72) json/3.10.5                  88) py-six/1.16.0            104) jedi-base-env/1.0.0    120) py-docutils/0.19
  9) python/3.10.13            25) fms/2023.04             41) boost/1.84.0             57) git-lfs/3.3.0     73) json-schema-validator/2.1.0  89) py-python-dateutil/2.8.2 105) gftl/1.11.0            121) py-jmespath/1.0.1
 10) stack-python/3.10.13      26) libjpeg/2.1.0           42) openblas/0.3.24          58) sp/2.5.0          74) odc/1.4.6                    90) py-pytz/2023.3           106) gftl-shared/1.6.1      122) py-wcwidth/0.2.7
 11) bacio/2.4.1               27) jasper/2.0.32           43) py-setuptools/63.4.3     59) gsibec/1.2.1      75) py-attrs/21.4.0              91) py-pyxlsb/1.0.10         107) fargparse/1.6.0        123) py-prompt-toolkit/3.0.38
 12) snappy/1.1.10             28) libpng/1.6.37           44) py-numpy/1.22.3          60) gsl-lite/0.37.0   76) py-pycparser/2.21            92) py-xlrd/2.0.1            108) yafyaml/1.2.0          124) py-ruamel-yaml/0.17.16
 13) zstd/1.5.2                29) w3emc/2.10.0            45) bufr/12.0.1              61) krb5/1.20.1       77) py-cffi/1.15.1               93) py-xlsxwriter/3.1.7      109) pflogger/1.12.0        125) py-ruamel-yaml-clib/0.2.7
 14) c-blosc/1.21.5            30) g2/3.4.9                46) ecbuild/3.7.2            62) libtirpc/1.3.3    78) py-findlibs/0.0.2            94) py-xlwt/1.3.0            110) mapl/2.40.3-esmf-8.6.0 126) py-urllib3/1.26.12
 15) nghttp2/1.57.0            31) g2tmpl/1.10.2           47) openjpeg/2.3.1           63) hdf/4.2.15        79) py-eccodes/1.5.0             95) py-pandas/1.5.3          111) nemsio/2.5.4           127) awscli-v2/2.13.22
 16) curl/8.4.0                32) ip/5.0.0                48) eccodes/2.33.0           64) jedi-cmake/1.4.0  80) py-f90nml/1.4.3              96) py-pybind11/2.11.0       112) sfcio/1.4.1
```

On a pre-configured platform that has spack-stack-1.7.0 installed, load the spack-stack modules as described in https://spack-stack.readthedocs.io/en/1.7.0. On a configurable (user) platform, follow the instructions in https://spack-stack.readthedocs.io/en/1.7.0 to build the `skylab-dev` or `unified-dev` environment, then run (use the appropriate path, compiler/mpi/python versions for your system):
```
module use /Users/heinzell/prod/spack-stack-1.7.0/envs/unified-dev/install/modulefiles/Core
module load stack-apple-clang/13.1.6
module load stack-openmpi/5.0.1
module load stack-python/3.10.13
```

For pre-configured and configurable platforms, proceed with laoding the following modules
```
module load jedi-ufs-env
module load awscli-v2/2.13.22
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
When using the native Apple `clang` compiler on macOS with `llvm-openmp` installed via homebrew or spack, it may be necessary to add `-DCMAKE_SHARED_LINKER_FLAGS="${LLVM_OPENMP_ROOT}/lib/libomp.dylib"` to the `cmake` command. We have identified this beig an issue with FMS not declaring its OpenMP dependencies correctly. A bug fix was merged for FMS recently, once the next tag finds its way into spack-stack this will no longer be needed.

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
