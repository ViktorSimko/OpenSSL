#!/usr/bin/env bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TMP_DIR=$( mktemp -d )

build_ios() {

   local ARCH=$1

   cp "${SCRIPT_DIR}/ios/iPhoneOS/${ARCH}/lib/libssl.a" "${SCRIPT_DIR}/ios/lib/libssl.a"
   cp "${SCRIPT_DIR}/ios/iPhoneOS/${ARCH}/lib/libcrypto.a" "${SCRIPT_DIR}/ios/lib/libcrypto.a"

   xcodebuild -project OpenSSL.xcodeproj \
      ARCHS=${ARCH} \
      ONLY_ACTIVE_ARCH=NO \
      -scheme 'OpenSSL (iOS)' \
      -sdk iphoneos \
      -destination 'generic/platform=iOS' \
      -configuration 'Release' \
      SYMROOT="${SCRIPT_DIR}/build/${ARCH}" \
      -derivedDataPath ./DerivedData \
      BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
      build
}

build_ios_simulator() {

   local ARCH=$1

   cp "${SCRIPT_DIR}/ios/iPhoneSimulator/${ARCH}/lib/libssl.a" "${SCRIPT_DIR}/ios/lib/libssl.a"
   cp "${SCRIPT_DIR}/ios/iPhoneSimulator/${ARCH}/lib/libcrypto.a" "${SCRIPT_DIR}/ios/lib/libcrypto.a"

   xcodebuild -project OpenSSL.xcodeproj \
      ARCHS=${ARCH} \
      ONLY_ACTIVE_ARCH=NO \
      -scheme 'OpenSSL (iOS)' \
      -sdk iphonesimulator \
      -destination 'generic/platform=iOS Simulator' \
      -configuration 'Release' \
      SYMROOT="${SCRIPT_DIR}/build/${ARCH}" \
      -derivedDataPath ./DerivedData \
      BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
      build
}

rm -rf "${SCRIPT_DIR}/build/OpenSSL.xcframework"

cp "${SCRIPT_DIR}/ios/lib/libssl.a" "${TMP_DIR}/libssl.a"
cp "${SCRIPT_DIR}/ios/lib/libcrypto.a" "${TMP_DIR}/libcrypto.a"

build_ios "arm64"

build_ios_simulator "x86_64"

ARM64_LIB="$(ls -A ${SCRIPT_DIR}/ios/iPhoneSimulator/arm64/lib)"

[ ! -z "$ARM64_LIB" ] && build_ios_simulator "arm64"

xcodebuild -create-xcframework \
  -framework 'build/arm64/Release-iphoneos/OpenSSL.framework' \
  -framework 'build/x86_64/Release-iphonesimulator/OpenSSL.framework' \
  ${ARM64_LIB:+"-framework 'build/arm64/Release-iphonesimulator/OpenSSL.framework'"} \
  -output 'build/OpenSSL.xcframework'

cp "${TMP_DIR}/libssl.a" "${SCRIPT_DIR}/ios/lib/libssl.a" 
cp "${TMP_DIR}/libcrypto.a" "${SCRIPT_DIR}/ios/lib/libcrypto.a" 

rm -rf "${TMP_DIR}"

echo "all done"
