#!/bin/bash
set -e
set -x

################################################################################
# This section adapted from:
# * https://gitlab.com/nvidia/cuda/blob/centos6/8.0/runtime/Dockerfile
# * https://gitlab.com/nvidia/cuda/blob/centos6/8.0/devel/Dockerfile
################################################################################

NVIDIA_GPGKEY_SUM=d1be581509378368edeec8c1eb2958702feedf3bc3d17011adbf24efacce4ab5
curl -fsSL http://developer.download.nvidia.com/compute/cuda/repos/rhel6/x86_64/7fa2af80.pub | sed '/^Version/d' > /etc/pki/rpm-gpg/RPM-GPG-KEY-NVIDIA
echo "$NVIDIA_GPGKEY_SUM  /etc/pki/rpm-gpg/RPM-GPG-KEY-NVIDIA" | sha256sum -c -

cp /pytorch/.travis/cuda.repo /etc/yum.repos.d/cuda.repo

export CUDA_VERSION=8.0
export CUDA_PKG_VERSION=8-0-8.0.61-1

yum install -y \
    cuda-command-line-tools-$CUDA_PKG_VERSION \
    cuda-core-$CUDA_PKG_VERSION \
    cuda-cublas-dev-$CUDA_PKG_VERSION \
    cuda-cudart-dev-$CUDA_PKG_VERSION \
    cuda-curand-dev-$CUDA_PKG_VERSION \
    cuda-cusparse-dev-$CUDA_PKG_VERSION \
    cuda-driver-dev-$CUDA_PKG_VERSION \
    cuda-misc-headers-$CUDA_PKG_VERSION \
    cuda-nvml-dev-$CUDA_PKG_VERSION \
    cuda-nvrtc-dev-$CUDA_PKG_VERSION
ln -s cuda-$CUDA_VERSION /usr/local/cuda

echo "/usr/local/cuda/lib64" >> /etc/ld.so.conf.d/cuda.conf
ldconfig
echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf
echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf
export PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
export LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64
export LIBRARY_PATH=/usr/local/cuda/lib64/stubs:${LIBRARY_PATH}

################################################################################
# This section adapted from:
# * https://gitlab.com/nvidia/cuda/blob/centos6/8.0/devel/cudnn5/Dockerfile
################################################################################

CUDNN_DOWNLOAD_SUM=c10719b36f2dd6e9ddc63e3189affaa1a94d7d027e63b71c3f64d449ab0645ce
curl -fsSL http://developer.download.nvidia.com/compute/redist/cudnn/v5.1/cudnn-8.0-linux-x64-v5.1.tgz -O
echo "$CUDNN_DOWNLOAD_SUM  cudnn-8.0-linux-x64-v5.1.tgz" | sha256sum -c -
tar -xzf cudnn-8.0-linux-x64-v5.1.tgz -C /usr/local
rm cudnn-8.0-linux-x64-v5.1.tgz
ldconfig

################################################################################
# This section adapted from:
# * https://github.com/pytorch/pytorch/blob/master/Dockerfile
################################################################################

yum install -y \
    cmake \
    curl \
    git \
    libjpeg-devel \
    libpng-devel

################################################################################
# This section adapted from:
# * https://github.com/lukeyeager/python-manylinux-demo/blob/master/travis/build-wheels.sh
################################################################################

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    if [[ $PYBIN == *"26"* ]]; then
        # Python 2.6 is not supported
        continue
    fi
    "${PYBIN}/pip" install -r /pytorch/requirements.txt
    "${PYBIN}/pip" wheel /pytorch -w /pytorch/dist/
done

# Bundle external shared libraries into the wheels
for whl in /pytorch/dist/*.whl; do
    auditwheel repair "$whl" -w /pytorch/dist/
done
