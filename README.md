# ufs-bundle

Bundle for interfacing UFS models with JEDI interfaces

## Required thirdparty libraries

This bundle requires the following spack-stack modules be loaded (all except `fms@2022.04` are in the `skylab-3.0.0` environment):
```
> module li

Currently Loaded Modules:
  1) stack-apple-clang/13.1.6  22) esmf/8.4.2               43) ecbuild/3.7.2     64) netcdf-cxx4/4.3.1            85) py-pandas/1.4.0
  2) zlib/1.2.13               23) llvm-openmp/16.0.0       44) openjpeg/2.3.1    65) json/3.10.5                  86) py-pybind11/2.8.1
  3) pigz/2.7                  24) fms/2023.01              45) eccodes/2.27.0    66) json-schema-validator/2.1.0  87) py-pycodestyle/2.8.0
  4) zstd/1.5.2                25) libjpeg/2.1.0            46) eigen/3.4.0       67) odc/1.4.6                    88) py-pyhdf/0.10.4
  5) tar/1.34                  26) jasper/2.0.32            47) openblas/0.3.19   68) py-attrs/22.2.0              89) libyaml/0.2.5
  6) gettext/0.21.1            27) libpng/1.6.37            48) eckit/1.23.0      69) py-pycparser/2.21            90) py-pyyaml/6.0
  7) libxcrypt/4.4.33          28) g2/3.4.5                 49) fftw/3.3.10       70) py-cffi/1.15.1               91) py-gast/0.5.3
  8) sqlite/3.40.1             29) g2tmpl/1.10.2            50) fckit/0.10.1      71) py-findlibs/0.0.2            92) py-beniget/0.4.1
  9) python/3.10.8             30) sp/2.3.3                 51) fiat/1.1.0        72) py-setuptools/59.4.0         93) py-ply/3.11
 10) stack-python/3.10.8       31) ip/3.3.3                 52) ectrans/1.2.0     73) py-numpy/1.22.3              94) py-pythran/0.12.2
 11) pmix/4.2.3                32) cmake/3.23.1             53) atlas/0.33.0      74) py-eccodes/1.4.2             95) py-scipy/1.9.3
 12) openmpi/4.1.5             33) git/2.36.0               54) gsibec/1.1.2      75) py-f90nml/1.4.3              96) py-xarray/2022.3.0
 13) stack-openmpi/4.1.5       34) libbacktrace/2020-02-19  55) gsl-lite/0.37.0   76) py-h5py/3.7.0                97) jedi-base-env/1.0.0
 14) bacio/2.4.1               35) nccmp/1.9.0.1            56) hdf/4.2.15        77) py-cftime/1.0.3.4            98) gftl/1.10.0
 15) curl/8.0.1                36) py-pip/23.0              57) jedi-cmake/1.4.0  78) py-netcdf4/1.5.3             99) gftl-shared/1.5.0
 16) pkg-config/0.29.2         37) wget/1.21.3              58) libxt/1.1.5       79) py-bottleneck/1.3.5         100) mapl/2.35.2-esmf-8.4.2
 17) hdf5/1.14.0               38) base-env/1.0.0           59) libxmu/1.1.2      80) py-packaging/23.0           101) w3nco/2.4.1
 18) netcdf-c/4.9.2            39) boost/1.78.0             60) libxpm/3.5.12     81) py-numexpr/2.8.3            102) nemsio/2.5.2
 19) netcdf-fortran/4.6.0      40) bufr/11.7.1              61) libxaw/1.0.13     82) py-six/1.16.0               103) sigio/2.3.2
 20) parallel-netcdf/1.12.2    41) git-lfs/3.1.4            62) udunits/2.2.28    83) py-python-dateutil/2.8.2    104) w3emc/2.9.2
 21) parallelio/2.5.9          42) crtm/v2.4.1-jedi         63) ncview/2.1.8      84) py-pytz/2022.2.1            105) jedi-ufs-env/unified-dev
```
On a pre-configured platform (including an AWS single-node/parallelcluster instance based on a spack-stack AMI), load the spack-stack modules for `skylab-5.0.0` as described in https://spack-stack.readthedocs.io/en/1.4.0 and https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/1.8.0.

On a configurable (user) platform, follow the instructions in https://spack-stack.readthedocs.io/en/1.4.0 and https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/1.8.0 to build the `skylab-env` environment, then run (use the appropriate path, compiler/mpi/python versions for your system):
```
module use /Users/heinzell/prod/spack-stack-v1/envs/skylab-env/install/modulefiles/Core
module load stack-apple-clang/13.1.6
module load stack-openmpi/4.1.5
module load stack-python/3.10.8
module load jedi-ufs-env/skylab-dev
```

## Building ufs-bundle

The bundle can be built in three different configuragions: with fv3-jedi and the UFS configured for atmosphere-only, 
with soca and the UFS configured with a data-atmosphere using NG-GODAS, or with fv3-jedi and soca and the UFS
configured with S2S coupling. Only the first two configurations have test cases and are known to work, but all will build.

The parameter for specifying the configuration type is `-DAPP=[ATM|NG-GODAS|S2S]` on the ecbuild configuration line. Create a build directory under/outside `ufs-bundle` and `cd` to it. Then run one of the following `ecbuild` commands:
```
ecbuild --build=debug -DUFS_APP=ATM .. 2>&1 | tee log.ecbuild
ecbuild --build=debug -DUFS_APP=ATMAERO .. 2>&1 | tee log.ecbuild
ecbuild --build=debug -DUFS_APP=NG-GODAS .. 2>&1 | tee log.ecbuild
ecbuild --build=debug -DUFS_APP=S2S .. 2>&1 | tee log.ecbuild
```
When using the native Apple `clang` compiler on macOS with `llvm-openmp` installed via homebrew or spack, it may be necessary to add `-DCMAKE_SHARED_LINKER_FLAGS="$llvm_openmp_ROOT/lib/libomp.dylib"` to the ecbuild command.

While building with soca (NG-GODAS or S2S), there will be a long pause during configuration when `ecbuild` is downloading the input files for the test to be run.

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

Note for later for running on Hera: need to add `-DMPIEXEC_EXECUTABLE="/apps/slurm/default/bin/srun" -DMPIEXEC_NUMPROC_FLAG="-n"` to `ecbuild` command, then run `ctest -R get_` on login node, then acquire a compute node, for example via `salloc -N 1 -n 24 --time=480 --qos=batch -A da-cpu -I`, then run the actual `ctests` on the compute node.
