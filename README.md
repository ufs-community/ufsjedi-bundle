# ufs-jedi-bundle

Bundle for interfacing UFS models with JEDI interfaces

This bundle requires the following spack-stack modules be loaded (not all are in skylab-2.0.0 environment):

heinzell@JCSDA-L-18146:~/work/ufs-bundle/ufs-bundle/build-debug-ng-godas [brew-x86_64]> module li

Currently Loaded Modules:
  1) stack-apple-clang/13.1.6  19) base-env/1.0.0   37) hdf/4.2.15                   55) py-pycparser/2.20         73) py-pandas/1.4.0       91) py-botocore/1.13.44  109) py-pyshp/2.1.0            127) g2/3.4.5
  2) pmix/4.1.2                20) boost/1.78.0     38) jedi-cmake/1.4.0             56) py-cffi/1.15.0            74) py-pybind11/2.8.1     92) py-s3transfer/0.2.1  110) py-shapely/1.8.0          128) g2tmpl/1.10.0
  3) zlib/1.2.12               21) bufr/11.7.1      39) libpng/1.6.37                57) py-findlibs/0.0.2         75) py-pycodestyle/2.8.0  93) py-boto3/1.10.44     111) py-cartopy/0.20.2         129) ip/3.3.3
  4) openmpi/4.1.4             22) git-lfs/3.1.4    40) libxt/1.1.5                  58) py-setuptools/59.4.0      76) py-pyhdf/0.10.4       94) brunsli/0.1          112) py-markupsafe/2.0.1       130) gftl-shared/1.5.0
  5) stack-openmpi/4.1.4       23) ecbuild/3.6.5    41) libxmu/1.1.2                 59) py-numpy/1.22.3           77) py-pyyaml/6.0         95) geos/3.9.1           113) py-jinja2/3.0.3           131) yafyaml/0.5.1
  6) stack-python/3.9.13       24) openjpeg/2.3.1   42) pigz/2.7                     60) py-eccodes/1.4.2          78) llvm-openmp/14.0.6    96) json-c/0.16          114) py-ruamel-yaml/0.17.16    132) mapl/2.22.0-esmf-8.3.0b09-esmf-8.3.0
  7) cmake/3.23.1              25) eccodes/2.27.0   43) zstd/1.5.2                   61) py-f90nml/1.4.2           79) py-gast/0.5.3         97) lerc/3.0             115) py-ruamel-yaml-clib/0.2.4 133) ufs-pyenv/1.0.0
  8) curl/7.83.0               26) eigen/3.4.0      44) tar/1.34                     62) py-mpi4py/3.1.2           80) py-beniget/0.4.1      98) sqlite/3.38.5        116) jedi-ewok-env/1.0.0       134) w3nco/2.4.1
  9) git/2.36.0                27) openblas/0.3.19  45) gettext/0.21                 63) py-h5py/3.6.0             81) py-ply/3.11           99) proj/8.1.0           117) antlr/2.7.7               135) ufs-weather-model-env/1.0.0
 10) pkg-config/0.29.2         28) eckit/1.19.0     46) libxpm/3.5.12                64) py-cftime/1.0.3.4         82) py-pythran/0.11.0    100) gdal/3.5.1           118) gsl/2.7.1                 136) crtm/v2.4_jedi
 11) hdf5/1.12.1               29) fftw/3.3.10      47) libxaw/1.0.13                65) py-netcdf4/1.5.3          83) py-scipy/1.8.0       101) py-cycler/0.11.0     119) nco/5.0.6                 137) w3emc/2.9.1
 12) libbacktrace/2020-02-19   30) fckit/0.9.5      48) udunits/2.2.28               66) py-bottleneck/1.3.2       84) py-xarray/2022.3.0   102) py-fonttools/4.31.2  120) soca-env/1.0.0            138) nemsio/2.5.2
 13) parallel-netcdf/1.12.2    31) fiat/1.0.0       49) ncview/2.1.8                 67) py-pyparsing/3.0.6        85) jedi-base-env/1.0.0  103) py-kiwisolver/1.3.2  121) sp/2.3.3
 14) netcdf-c/4.8.1            32) ectrans/1.0.0    50) netcdf-cxx4/4.3.1            68) py-packaging/21.3         86) jedi-fv3-env/1.0.0   104) py-pillow/9.2.0      122) sigio/2.3.2
 15) nccmp/1.9.0.1             33) atlas/0.30.0     51) json/3.10.5                  69) py-numexpr/2.8.3          87) ecflow/5.8.3         105) py-matplotlib/3.5.3  123) fms/2022.01
 16) netcdf-fortran/4.5.4      34) gsibec/1.0.5     52) json-schema-validator/2.1.0  70) py-six/1.16.0             88) py-docutils/0.18.1   106) py-certifi/2021.10.8 124) bacio/2.4.1
 17) parallelio/2.5.7          35) gsl-lite/0.37.0  53) odc/1.4.5                    71) py-python-dateutil/2.8.2  89) py-jmespath/0.10.0   107) py-cython/0.29.30    125) esmf/8.3.0b09
 18) wget/1.21.3               36) libjpeg/2.1.0    54) py-attrs/21.4.0              72) py-pytz/2021.3            90) py-urllib3/1.25.9    108) py-pyproj/3.1.0      126) jasper/2.0.32

Basically, do this:

module use /Users/heinzell/prod/spack-stack-v1/envs/skylab-2.0.0-plus-ufs/install/modulefiles/Core
module load stack-apple-clang/13.1.6
module load stack-openmpi/4.1.4
module load stack-python/3.9.13
module load jedi-fv3-env/1.0.0
module load jedi-ewok-env/1.0.0
module load soca-env/1.0.0
# Loading ufs-weather-model-env replaces the JEDI version of FMS and CRTM
module load ufs-weather-model-env/1.0.0
# Need to reload JEDI CRTM
module load crtm/v2.4_jedi
module load sigio/2.3.2
module load w3emc/2.9.1
module load nemsio/2.5.2

The bundle can be built in three different configuragions--with fv3-jedi and the UFS configured for atmosphere-only, 
with soca and the UFS configured with a data-atmosphere using NG-GODAS, or with fv3-jedi and soca and the UFS
configured with S2S coupling. Only the first two configurations have test cases and are known to work, but all will build.

The parameter for specifying the configuration type is "-DAPP=(ATM/NG-GODAS/S2S)" on the ecbuild configuration line. Create a build directory under ufs-jedi-bundle and cd to it. Then run the following ecbuild command (substitute "ATM" for "NG-GODAS" as desired):

ecbuild --build=debug -DUFS_APP=ATM .. 2>&1 | tee log.ecbuild
ecbuild --build=debug -DUFS_APP=NG-GODAS .. 2>&1 | tee log.ecbuild
# Note - not yet tested on macOS with spack-stack
#ecbuild --build=debug -DUFS_APP=S2S .. 2>&1 | tee log.ecbuild

On macOS, it may be required to pass -DCMAKE_EXE_LINKER_FLAGS="-Wl,-no_compact_unwind" to the ecbuild command.

While building with SOCA (NG-GODAS or S2S) there will be a long pause during configuration when ecbuild is downloading the input files for the test to be run.

After configuration, run "make -j 8" to build.

The ctests for ATM are called fv3jedi_test_tier1_model_ufs and fv3jedi_test_tier1_forecast_ufs.
The ctest for NG-GODAS is called test_soca_forecast_ufs.

Note for later for running on Hera: need to add -DMPIEXEC_EXECUTABLE="/apps/slurm/default/bin/srun" -DMPIEXEC_NUMPROC_FLAG="-n" to cmake/ecbuild command, then run ctest -R get_ on login node, then acquire compute node, for example via salloc -N 1 -n 24 --time=480 --qos=batch -A da-cpu, then run the actual ctests on login node.






#### OLD STUFF FROM MARK FOR BUILDING ON HERA WITH OLD SOFTWARE STACK

# ufs-jedi-bundle
Bundle for interfacing UFS models with JEDI interfaces

This bundle requires the following modules be loaded--
compiler gnu 9.0+ or intel 18+
MPI
esmf-8.2+ hdf5 netcdf eckit fckit eigen boost atlas-0.27+ pio mkl/openblas 
parallel-netcdf cmake-3.20+ ecbuild udunits bacio w3nco w3emc nemsio sigio sfcio sp expat gsl-lite

The bundle can be built in three different configuragions--with fv3-jedi and the UFS configured for atmosphere-only, 
with soca and the UFS configured with a data-atmosphere using NG-GODAS, or with fv3-jedi and soca and the UFS
configured with S2S coupling. Only the first two configurations have test cases and are known to work, but all will build.

The parameter for specifying the configuration type is "-DAPP=(ATM/NG-GODAS/S2S)" on the ecbuild configuration line.

To build on Hera, load the following modules--
module use /scratch2/NCEPDEV/nwprod/hpc-stack/libs/hpc-stack/modulefiles/stack
module load hpc hpc-gnu hpc-mpich
module load esmf/8.3.0b09 hdf5 netcdf eckit fckit cmake gsl-lite bacio sfcio sp eigen boost-headers atlas pio ecbuild udunits nemsio/2.5.2 w3emc/2.9.2 sigio 

create a build directory under ufs-jedi-bundle and cd to it. Then run the following ecbuild command (substitute "ATM" for "NG-GODAS" as desired.

ecbuild -DLAPACK_LIBRARIES="/scratch1/NCEPDEV/jcsda/jedipara/opt/modules/gnu-9.2.0/lapack/3.8.0/lib/liblapack.a;/scratch1/NCEPDEV/jcsda/jedipara/opt/modules/gnu-9.2.0/lapack/3.8.0/lib/libblas.a" -DBLAS_openblas_LIBRARY:FILEPATH=/scratch1/NCEPDEV/jcsda/jedipara/opt/modules/gnu-9.2.0/lapack/3.8.0/lib/libblas.a -DMPI_Fortran_LINK_FLAGS="-lexpat" -DBUNDLE_SKIP_ATLAS=OFF -DBUILD_TESTING=TRUE -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_Fortran_COMPILER=mpifort -DMPI_CXX_LINK_FLAGS:STRING="-Wl,--copy-dt-needed-entries" -DCMAKE_BUILD_TYPE=DEBUG -DUFS_APP=NG-GODAS .. 


NOTE: WITH SPACK-STACK, I DIDN'T NEED ANY OF THIS ... just do "ecbuild --build=debug -DUFS_APP=ATM .. 2>&1 | tee log.ecbuild"

ecbuild --build=debug -DUFS_APP=NG-GODAS .. 2>&1 | tee log.ecbuild

ecbuild --build=debug -DUFS_APP=S2S .. 2>&1 | tee log.ecbuild

While building with SOCA (NG-GODAS or S2S) there will be a long pause during configuration when ecbuild is downloading the input files for the test to be run.

After configuration, run "make -j 8" to build. The ctest for NG-GODAS is called test_soca_forecast_ufs, but the ctests using mpich don't run out of the box on
Hera. You will need to run it manually from the build/soca/test directory. Cd to that directory and run the following to test the forecast--

NO, FIX AND USE -DMPIEXEC_EXECUTABLE ETC. THEN SALLOC

srun --mpi=pmi2 -n 8 ../../bin/soca_forecast.x testinput/forecast_ufs.yml


The code will build on Cheyenne, but there is some sort of mpi issue when trying to run. Here are the steps to build--

module use /glade/work/epicufsrt/GMTB/tools/gnu/10.1.0/hpc-stack-v1.2.0/modulefiles/stack
module load gnu/10.1.0 mpt/2.22 hpc hpc-gnu hpc-mpt/2.22
module load hdf5/1.10.6 esmf/8.3.0b09 netcdf/4.7.4 eckit fckit eigen boost pnetcdf pio/2.5.3 ecbuild udunits bacio w3nco w3emc nemsio sigio sfcio sp expat gsl-lite openblas cmake/3.22.0 python/3.7.9 git

git lfs install

ecbuild -DMPI_Fortran_LINK_FLAGS="-lexpat" -DCMAKE_PREFIX_PATH=/glade/work/epicufsrt/GMTB/tools/intel/2022.1/hpc-stack-v1.2.0_6eb6/core/gsl-lite/0.37.0/lib64/cmake -DBLAS_openblas_LIBRARY:FILEPATH=$NCAR_ROOT_OPENBLAS/lib/libopenblas.so -DBUNDLE_SKIP_ATLAS=OFF -DBUILD_TESTING=TRUE -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_Fortran_COMPILER=mpif90 -DMPI_CXX_LINK_FLAGS:STRING="-Wl,--copy-dt-needed-entries" -DCMAKE_BUILD_TYPE=DEBUG -DUFS_APP=NG-GODAS ..

