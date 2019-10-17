#!/bin/bash -xe

#----------------------------------------------------------------------

OPENSSL_VERSION=1.1.1d
export IPHONEOS_DEPLOYMENT_TARGET="9.3"

#----------------------------------------------------------------------

OPENSSL_DIR=~/openssl/ios

#----------------------------------------------------------------------

CWD=$(cd $(dirname $0); pwd)

#----------------------------------------------------------------------

build_openssl_ios_arch() {
  ARCH=$1 # arm64       | x86_64
  SDK=$2  # iphoneos    | iphonesimulator
  HOST=$3 # ios64-xcrun | darwin64-x64_64-cc

  # -----

  BUILD_DIR=${CWD}/build/ios_${ARCH?}
  OUTPUT_DIR=${CWD}/output/ios_${ARCH?}
  SDKDIR=$(xcrun --sdk ${SDK?} --show-sdk-path)
  export CC=$(xcrun --find --sdk ${SDK?} clang)

  # -----

  OPENSSL_DOWNLOAD_URI=https://www.openssl.org/source/openssl-${OPENSSL_VERSION?}.tar.gz
  OPENSSL_DOWNLOAD=~/Downloads/openssl-${OPENSSL_VERSION?}.tar.gz
  if [ ! -f ${OPENSSL_DOWNLOAD?} ]; then
    curl ${OPENSSL_DOWNLOAD_URI?} -o ${OPENSSL_DOWNLOAD?}
  fi

  # -----

  if [ -d ${BUILD_DIR?} ]; then
    rm -rf ${BUILD_DIR}
  fi
  mkdir -p ${BUILD_DIR?}
  cd ${BUILD_DIR?}
  tar -xzf ${OPENSSL_DOWNLOAD?}

  # -----

  BUILD_CPUS=$(sysctl -n hw.logicalcpu_max)
  BUILD_LOG=${BUILD_DIR?}.log
  export CFLAGS="-arch ${ARCH} -pipe -Os -gdwarf-2 -isysroot ${SDKDIR} -miphoneos-version-min=${IPHONEOS_DEPLOYMENT_TARGET}"
  export LDFLAGS="-arch ${ARCH} -isysroot ${SDKDIR}"
  cd ${BUILD_DIR?}/openssl-${OPENSSL_VERSION?}
  ./configure --prefix=${OUTPUT_DIR?} \
    -no-shared -no-engine -no-async -no-hw ${HOST?} 2>&1 | tee "${BUILD_LOG?}"
  make -j ${BUILD_CPUS?} 2>&1 | tee -a "${BUILD_LOG?}"

  # -----

  if [ -d ${OUTPUT_DIR?} ]; then
    rm -rf ${OUTPUT_DIR?}
  fi
  mkdir -p ${OUTPUT_DIR?}
  cd ${BUILD_DIR?}/openssl-${OPENSSL_VERSION?}
  make install_sw install_ssldirs
}

#----------------------------------------------------------------------

build_openssl_ios() {
  OUTPUT_DIR_IOS=${CWD}/output/ios
  OUTPUT_DIR_IOS_ARM64=${CWD}/output/ios_arm64
  OUTPUT_DIR_IOS_X86_64=${CWD}/output/ios_x86_64

  # -----

  if [ -d ${OUTPUT_DIR_IOS?} ]; then
    rm -rf ${OUTPUT_DIR_IOS?}
  fi
  mkdir -p ${OUTPUT_DIR_IOS?}

  # -----

  tar -C ${OUTPUT_DIR_IOS_ARM64?} -cf - include | tar -C ${OUTPUT_DIR_IOS?} -xf -

  # -----

  mkdir -p ${OUTPUT_DIR_IOS?}/lib
  lipo                 ${OUTPUT_DIR_IOS_ARM64?}/lib/libssl.a \
       -arch x86_64    ${OUTPUT_DIR_IOS_X86_64?}/lib/libssl.a \
       -create -output ${OUTPUT_DIR_IOS?}/lib/libssl.a
  lipo                 ${OUTPUT_DIR_IOS_ARM64?}/lib/libcrypto.a \
       -arch x86_64    ${OUTPUT_DIR_IOS_X86_64?}/lib/libcrypto.a \
       -create -output ${OUTPUT_DIR_IOS?}/lib/libcrypto.a

  # -----
}

#----------------------------------------------------------------------

deploy_openssl_ios() {
  OUTPUT_DIR_IOS=${CWD}/output/ios

  # -----

  if [ -d ${OPENSSL_DIR?} ]; then
    rm -rf ${OPENSSL_DIR?}
  fi
  mkdir -p ${OPENSSL_DIR?}

  # -----

  tar -C ${OUTPUT_DIR_IOS?} -cf - lib include | tar -C ${OPENSSL_DIR?} -xf -
}

#----------------------------------------------------------------------

build_openssl_ios_arch arm64  iphoneos        ios64-xcrun
build_openssl_ios_arch x86_64 iphonesimulator darwin64-x86_64-cc
build_openssl_ios
deploy_openssl_ios

#----------------------------------------------------------------------

