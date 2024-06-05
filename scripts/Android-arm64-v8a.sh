#!/bin/bash
set -xe
apt update
apt install -y git curl automake libtool make cmake flex bison python
dir
export ARCH=arm64
export ANDROID_API=21
export COMPILER_PREFIX=aarch64-linux-android
export INSTALL_PREFIX=/opt/android-toolchain
export TOOLCHAIN=${INSTALL_PREFIX}-${ARCH}
export PATH="${TOOLCHAIN}/bin:${PATH}"
$ANDROID_NDK/build/tools/make_standalone_toolchain.py \
        --arch ${ARCH} \
        --api ${ANDROID_API} \
        --install-dir ${TOOLCHAIN}
export HOST=${COMPILER_PREFIX}
export SYSROOT=/opt/android-ndk-linux/sysroot
export PREFIX=${SYSROOT}/usr/local
dir
curl -L -o libpcap-1.9.0.tar.gz https://github.com/the-tcpdump-group/libpcap/archive/libpcap-1.9.0.tar.gz
tar xvf libpcap-1.9.0.tar.gz
cd libpcap-libpcap-1.9.0 \
    && ./configure \
         --host=$HOST \
         --prefix=$PREFIX \
         --disable-shared \
    && make -j$(nproc) \
    && make install 
cd ..
dir
mkdir build
dir
cd build
# -DLIBUV_LIBRARIES=/opt/android-ndk-linux/sysroot/usr/local/lib/libuv.a \
# -DLIBUV_INCLUDE_DIR=/opt/android-ndk-linux/sysroot/usr/local/include \
cmake \
    -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
    -DPCAP_ROOT_DIR=$ANDROID_NDK/sysroot/usr/local \
    -DCMAKE_BUILD_TYPE=Release \
    -DANDROID_NDK=$ANDROID_NDK \
    -DANDROID_PLATFORM=android-21 \
    -DBUILD_SHARED_LIBS=NO \
    -DANDROID_ABI=arm64-v8a ..
make
mv ./src/lan-play ./src/lan-play-arm64-v8a