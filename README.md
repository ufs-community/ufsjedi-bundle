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

The following ecbuild line will configure the NG-GODAS application on Hera--

ecbuild -DMPI_Fortran_LINK_FLAGS="-lexpat" -DBUNDLE_SKIP_ATLAS=OFF -DBUILD_TESTING=TRUE -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_Fortran_COMPILER=mpifort -DMPI_CXX_LINK_FLAGS:STRING="-Wl,--copy-dt-needed-entries" -DCMAKE_BUILD_TYPE=DEBUG -DUFS_APP=NG-GODAS .. 


