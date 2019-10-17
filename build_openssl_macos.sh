#!/bin/bash -xe

#----------------------------------------------------------------------

OPENSSL_VERSION=1.1.1d
OPENSSL_DIR=~/openssl/macos

#----------------------------------------------------------------------


CWD=$(cd $(dirname $0); pwd)

#----------------------------------------------------------------------

build_openssl_macos() {
  BUILD_DIR=${CWD}/build/macos
  OUTPUT_DIR=${CWD}/output/macos

  # -----

  OPENSSL_DOWNLOAD_URI=https://www.openssl.org/source/openssl-${OPENSSL_VERSION?}.tar.gz
  OPENSSL_DOWNLOAD=~/Downloads/openssl-${OPENSSL_VERSION?}.tar.gz
  if [ ! -f ${OPENSSL_DOWNLOAD?} ]; then
    curl ${OPENSSL_DOWNLOAD_URI?} -o ${OPENSSL_DOWNLOAD?}
  fi

  # -----

  if [ -d ${BUILD_DIR?} ]; then
    rm -rf ${BUILD_DIR?}
  fi
  mkdir -p ${BUILD_DIR?}
  cd ${BUILD_DIR?}
  tar -xzf ${OPENSSL_DOWNLOAD?}

  # -----

  BUILD_CPUS=$(sysctl -n hw.logicalcpu_max)
  BUILD_LOG=${BUILD_DIR?}.log
  cd ${BUILD_DIR?}/openssl-${OPENSSL_VERSION?}
  ./configure --prefix=${OUTPUT_DIR?} \
      darwin64-x86_64-cc 2>&1 | tee "${BUILD_LOG?}"
  make -j ${BUILD_CPUS?} 2>&1 | tee -a "${BUILD_LOG?}"

  # -----

  if [ -d ${OUTPUT_DIR?} ]; then
    rm -rf ${OUTPUT_DIR?}
  fi
  mkdir -p ${OUTPUT_DIR?}
  cd ${BUILD_DIR?}/openssl-${OPENSSL_VERSION?}
  make install
}

#----------------------------------------------------------------------

deploy_openssl_macos() {
  OUTPUT_DIR=${CWD}/output/macos
  if [ -d ${OPENSSL_DIR?} ]; then
    rm -rf ${OPENSSL_DIR?}
  fi
  mkdir -p ${OPENSSL_DIR?}
  tar -C ${OUTPUT_DIR?} -cf - . | tar -C ${OPENSSL_DIR?} -xf -
}

#----------------------------------------------------------------------

build_openssl_macos
deploy_openssl_macos

#----------------------------------------------------------------------

