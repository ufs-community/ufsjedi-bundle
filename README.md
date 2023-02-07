# ufs-bundle

Bundle for interfacing UFS models with JEDI interfaces

## Required thirdparty libraries

This bundle requires the following spack-stack modules be loaded (all except `fms@2022.04` are in the `skylab-3.0.0` environment):
```
> module li

Currently Loaded Modules:
  1) stack-apple-clang/13.1.6  18) libpng/1.6.37            35) openjpeg/2.3.1    52) zstd/1.5.2                   69) py-eccodes/1.4.2          86) py-pyyaml/6.0
  2) pmix/4.1.2                19) g2/3.4.5                 36) eccodes/2.27.0    53) tar/1.34                     70) py-f90nml/1.4.3           87) py-gast/0.5.3
  3) zlib/1.2.13               20) g2tmpl/1.10.0            37) eigen/3.4.0       54) gettext/0.21.1               71) py-mpi4py/3.1.4           88) py-beniget/0.4.1
  4) openmpi/4.1.4             21) sp/2.3.3                 38) openblas/0.3.19   55) libxpm/3.5.12                72) py-h5py/3.6.0             89) py-ply/3.11
  5) stack-openmpi/4.1.4       22) ip/3.3.3                 39) eckit/1.20.2      56) libxaw/1.0.13                73) py-cftime/1.0.3.4         90) py-pythran/0.11.0
  6) stack-python/3.9.13       23) cmake/3.23.1             40) fftw/3.3.10       57) udunits/2.2.28               74) py-netcdf4/1.5.3          91) py-scipy/1.8.0
  7) bacio/2.4.1               24) git/2.36.0               41) fckit/0.9.5       58) ncview/2.1.8                 75) py-bottleneck/1.3.5       92) py-xarray/2022.3.0
  8) curl/7.83.0               25) libbacktrace/2020-02-19  42) fiat/1.0.0        59) netcdf-cxx4/4.3.1            76) py-pyparsing/3.0.9        93) jedi-base-env/1.0.0
  9) pkg-config/0.29.2         26) nccmp/1.9.0.1            43) ectrans/1.1.0     60) json/3.10.5                  77) py-packaging/21.3         94) gftl-shared/1.5.0
 10) hdf5/1.12.1               27) parallelio/2.5.7         44) atlas/0.31.1      61) json-schema-validator/2.1.0  78) py-numexpr/2.8.3          95) yafyaml/0.5.1
 11) parallel-netcdf/1.12.2    28) wget/1.21.3              45) gsibec/1.0.6      62) odc/1.4.5                    79) py-six/1.16.0             96) mapl/2.22.0-esmf-8.3.0b09-esmf-8.3.0
 12) netcdf-c/4.8.1            29) base-env/1.0.0           46) gsl-lite/0.37.0   63) py-attrs/22.1.0              80) py-python-dateutil/2.8.2  97) w3nco/2.4.1
 13) netcdf-fortran/4.5.4      30) boost/1.78.0             47) hdf/4.2.15        64) py-pycparser/2.21            81) py-pytz/2022.2.1          98) nemsio/2.5.2
 14) esmf/8.3.0b09             31) bufr/11.7.1              48) jedi-cmake/1.4.0  65) py-cffi/1.15.0               82) py-pandas/1.4.0           99) sigio/2.3.2
 15) llvm-openmp/14.0.6        32) git-lfs/3.1.4            49) libxt/1.1.5       66) py-findlibs/0.0.2            83) py-pybind11/2.8.1        100) w3emc/2.9.2
 16) libjpeg/2.1.0             33) crtm/v2.4-jedi.2         50) libxmu/1.1.2      67) py-setuptools/59.4.0         84) py-pycodestyle/2.8.0     101) jedi-ufs-env/1.0.0
 17) jasper/2.0.32             34) ecbuild/3.6.5            51) pigz/2.7          68) py-numpy/1.22.3              85) py-pyhdf/0.10.4          102) fms/2022.04
```
On a pre-configured platform (including an AWS single-node/parallelcluster instance based on a spack-stack AMI), load the spack-stack modules for `skylab-3.0.0` as described in https://spack-stack.readthedocs.io/en/1.2.0 and https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/1.6.0, and run `module av` to see if `fms@2022.04` has already been installed. If yes, do
```
module load fms@2022.04
```
to swap the currently loaded `fms@2022.02` with `fms@2022.04`.

On a configurable (user) platform, follow the instructions in https://spack-stack.readthedocs.io/en/1.2.0 and https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/1.6.0 to build the `skylab-3.0.0`, then run (use the appropriate path, compiler/mpi/python versions for your system):
```
module use /Users/heinzell/prod/spack-stack-v1/envs/skylab-3.0.0/install/modulefiles/Core
module load stack-apple-clang/13.1.6
module load stack-openmpi/4.1.4
module load stack-python/3.9.13
module load jedi-ufs-env/1.0.0

# Loading fms@2022.04 replaces the default fms@2022.02
module load fms@2022.04
```

## Building ufs-bundle

The bundle can be built in three different configuragions: with fv3-jedi and the UFS configured for atmosphere-only, 
with soca and the UFS configured with a data-atmosphere using NG-GODAS, or with fv3-jedi and soca and the UFS
configured with S2S coupling. Only the first two configurations have test cases and are known to work, but all will build.

The parameter for specifying the configuration type is `-DAPP=[ATM|NG-GODAS|S2S]` on the ecbuild configuration line. Create a build directory under/outside `ufs-bundle` and `cd` to it. Then run one of the following `ecbuild` commands:
```
ecbuild --build=debug -DUFS_APP=ATM .. 2>&1 | tee log.ecbuild
ecbuild --build=debug -DUFS_APP=NG-GODAS .. 2>&1 | tee log.ecbuild
# Note - not yet tested on macOS with spack-stack
#ecbuild --build=debug -DUFS_APP=S2S .. 2>&1 | tee log.ecbuild
```
On macOS, it may be required to pass `-DCMAKE_EXE_LINKER_FLAGS="-Wl,-no_compact_unwind"` to the ecbuild command,. Further, if using the native Apple `clang` compiler with `llvm-openmp` installed via homebrew or spack, it may be necessary to add `-DCMAKE_SHARED_LINKER_FLAGS="/path/to/llvm-openmp-x.y.z/lib/libomp.dylib"` to the ecbuild command.

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
Note for later for running on Hera: need to add `-DMPIEXEC_EXECUTABLE="/apps/slurm/default/bin/srun" -DMPIEXEC_NUMPROC_FLAG="-n"` to `ecbuild` command, then run `ctest -R get_` on login node, then acquire a compute node, for example via `salloc -N 1 -n 24 --time=480 --qos=batch -A da-cpu -I`, then run the actual `ctests` on the compute node.
