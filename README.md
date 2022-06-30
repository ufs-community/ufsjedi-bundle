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
module load esmf/8.3.0b09 hdf5 netcdf eckit fckit cmake gsl-lite bacio sfcio sp eigen boost atlas pio intel-mkl parallel-netcdf ecbuild udunits nemsio/2.5.2 w3emc/2.9.2 sigio expat

create a build directory under ufs-jedi-bundle and cd to it. Then run the following ecbuild command (substitute "ATM" for "NG-GODAS" as desired.

ecbuild -DMPI_Fortran_LINK_FLAGS="-lexpat" -DBUNDLE_SKIP_ATLAS=OFF -DBUILD_TESTING=TRUE -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_Fortran_COMPILER=mpifort -DMPI_CXX_LINK_FLAGS:STRING="-Wl,--copy-dt-needed-entries" -DCMAKE_BUILD_TYPE=DEBUG -DUFS_APP=NG-GODAS .. 

While building with SOCA (NG-GODAS or S2S) there will be a long pause during configuration when ecbuild is downloading the input files for the test to be run.

After configuration, run "make -j 8" to build. The ctest for NG-GODAS is called test_soca_forecast_ufs, but the ctests using mpich don't run out of the box on
Hera. You will need to run it manually from the build/soca/test directory. Cd to that directory and run the following to test the forecast--

srun --mpi=pmi2 -n 8 /scratch1/NCEPDEV/da/Mark.Potts/jedi/ufs-jedi-bundle/build-gnu/bin/soca_forecast.x testinput/forecast_ufs.yml



