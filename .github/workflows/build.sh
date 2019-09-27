#!/bin/bash -xe

ccache -z
mkdir -p build
pushd build
j="$(grep -c processor /proc/cpuinfo 2>/dev/null)" || j=0; ((j++))
cmake .. -DENABLE_TESTING=ON -DBUILD_CSGAPPS=ON -DBUILD_XTP=ON -DBUILD_CSG_MANUAL=ON \
         -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DBUILD_OWN_GROMACS=${BUILD_GROMACS} -DENABLE_REGRESSION_TESTING=${REGRESSION_TESTING:-ON} \
         -DMODULE_BUILD=${MODULE_BUILD} ${MODULE_BUILD:+-DCMAKE_INSTALL_PREFIX=/home/votca/votca.install} \
         ${MINIMAL:+-DCMAKE_DISABLE_FIND_PACKAGE_HDF5=ON -DWITH_FFTW=OFF -DWITH_GSL=OFF -DCMAKE_DISABLE_FIND_PACKAGE_GSL=ON \
          -DWITH_MKL=OFF -DCMAKE_DISABLE_FIND_PACKAGE_MKL=ON -DBUILD_MANPAGES=OFF -DWITH_GMX=OFF -DWITH_SQLITE3=OFF \
          -DCMAKE_DISABLE_FIND_PACKAGE_SQLITE3=ON -DBUILD_XTP=OFF -DENABLE_REGRESSION_TESTING=OFF}
make -O -k -j${j} -l${j} VERBOSE=1
make test CTEST_OUTPUT_ON_FAILURE=1
test -z "${MODULE_BUILD}" && make install DESTDIR=${PWD}/install && rm -rf ${PWD}/install/usr && rmdir ${PWD}/install
sudo make install
if [[ ${CLANG_FORMAT} && ${CI_COMMIT_REF_NAME} != next ]]; then make format && git diff --submodule=diff --exit-code; fi
ccache -s
