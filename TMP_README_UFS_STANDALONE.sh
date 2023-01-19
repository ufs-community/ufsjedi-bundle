#!/bin/bash

# cd /mnt/experiments-efs/the-real-dom/ufs/
# source setup.sh
# git clone -b feature/consolidate_dom_update_20221114 --recursive https://github.com/climbfuji/ufs-weather-model ufs-weather-model-feature-consolidate_dom_update_20221114
# mkdir build-atm
# cd build-atm
# cmake -DAPP=ATM -DCCPP_SUITES=FV3_GFS_v16 -DMPI=ON -DOPENMP=ON -DINLINE_POST=OFF -DMULTI_GASES=OFF ../ufs-weather-model-feature-consolidate_dom_update_20221114 2>&1 | tee log.cmake
# make VERBOSE=1 -j4 2>&1 | tee log.make

cd /mnt/experiments-efs/the-real-dom/ufs/
mkdir -p test/ufs_c48_coldstart
cd test/ufs_c48_coldstart
ln -sf /mnt/experiments-efs/the-real-dom/ufs/static/atm_c48/* .
mkdir INPUT
cd INPUT
ln -sf /mnt/experiments-efs/the-real-dom/ufs/ic/atm_c48/2021072800/2021072800/* .
cd ..
mkdir RESTART
ln -sf /mnt/experiments-efs/the-real-dom/ufs/build-atm/ufs_model .