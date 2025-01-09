#!/usr/bin/env bash
# Python builder
set -ex

echo "Building PyTorch ${PYTORCH_BUILD_VERSION}"

# # install prerequisites
apt-get update
apt-get install -y --no-install-recommends \
    ninja-build libjpeg-dev libopenmpi-dev libomp-dev \
    libopenblas-dev libblas-dev libeigen3-dev \
    ccache \
    clang-8
ln -s /usr/bin/clang-8 /usr/bin/clang
ln -s /usr/bin/clang++-8 /usr/bin/clang++

# build from source
git clone --branch "v${PYTORCH_BUILD_VERSION}" --depth=1 --recursive https://github.com/pytorch/pytorch /opt/pytorch
cd /opt/pytorch

# https://github.com/pytorch/pytorch/issues/138333
# CPUINFO_PATCH=third_party/cpuinfo/src/arm/linux/aarch64-isa.c
# sed -i 's|cpuinfo_log_error|cpuinfo_log_warning|' ${CPUINFO_PATCH}
# grep 'PR_SVE_GET_VL' ${CPUINFO_PATCH}
# tail -20 ${CPUINFO_PATCH}

# Apply patches for CUDA thread limits and ARM NEON vectorization
# 1. Patch vec256_float_neon.h
sed -i '/\/\/ Most likely we will do aarch32 support with inline asm\./,/#if defined(__aarch64__)/c\// Most likely we will do aarch32 support with inline asm.\n#if defined(__aarch64__)\n#if defined(__clang__) ||(__GNUC__ > 8 || (__GNUC__ == 8 && __GNUC_MINOR__ > 3))' \
    aten/src/ATen/cpu/vec/vec256/vec256_float_neon.h
sed -i '/#error "Big endian is not supported."/a\#endif //defined(__clang__)' \
    aten/src/ATen/cpu/vec/vec256/vec256_float_neon.h

# Reduce max threads per block
sed -i '/device_properties\[device_index\] = device_prop;/i \ \ device_prop.maxThreadsPerBlock = device_prop.maxThreadsPerBlock / 2;' \
    aten/src/ATen/cuda/CUDAContext.cpp

# Fix CUDA thread limits for Jetson
sed -i 's/1024/512/g' aten/src/ATen/cuda/detail/KernelUtils.h

pip3 install --no-cache-dir --index-url https://pypi.org/simple -r requirements.txt
pip3 install --no-cache-dir --index-url https://pypi.org/simple \
    scikit-build ninja wheel mock pillow setuptools==58.3.0

# Set environment variables for build
export BUILD_CAFFE2_OPS=OFF
export USE_FBGEMM=OFF
export USE_FAKELOWP=OFF
export BUILD_TEST=OFF
export USE_MKLDNN=OFF
export USE_NNPACK=OFF
export USE_XNNPACK=OFF
export USE_QNNPACK=OFF
export USE_PYTORCH_QNNPACK=OFF
export USE_CUDA=ON
export USE_CUDNN=ON
export USE_NATIVE_ARCH=OFF  # Disable unsupported compiler flags
export TORCH_CUDA_ARCH_LIST="5.3;6.2;7.2;8.7"
export USE_NCCL=OFF
export USE_SYSTEM_NCCL=OFF
export USE_OPENCV=OFF
export MAX_JOBS=4
export BUILD_PYTHON=ON
export PYTHON_EXECUTABLE=/usr/local/bin/python3
export USE_DISTRIBUTED=ON
export USE_TENSORRT=OFF
export CC=clang
export CXX=clang++
export CUDACXX=/usr/local/cuda/bin/nvcc
export CUDA_HOME=/usr/local/cuda-10.2
export CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-10.2
export CUDA_PATH=$CUDA_HOME
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
export CUDNN_LIB_DIR=/usr/lib/aarch64-linux-gnu

PYTORCH_BUILD_NUMBER=1 \
TORCH_CXX_FLAGS="-D_GLIBCXX_USE_CXX11_ABI=0" \
USE_NATIVE_ARCH=1 \
USE_DISTRIBUTED=1 \
USE_CUDA=1 \
USE_TENSORRT=0 \
USE_FBGEMM=0 \
python3 setup.py bdist_wheel --dist-dir /opt

cd /
rm -rf /opt/pytorch

# install the compiled wheel
pip3 install /opt/torch*.whl
python3 -c 'import torch; print(f"PyTorch version: {torch.__version__}"); print(f"CUDA available:  {torch.cuda.is_available()}"); print(f"cuDNN version:   {torch.backends.cudnn.version()}"); print(torch.__config__.show());'
twine upload --verbose /opt/torch*.whl || echo "failed to upload wheel to ${TWINE_REPOSITORY_URL}"
