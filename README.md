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

# NOTE: WITH SPACK-STACK, I DIDN'T NEED ANY OF THIS ... just "ecbuild --build=debug -DUFS_APP=ATM .. 2>&1 | tee log.ecbuild"

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

