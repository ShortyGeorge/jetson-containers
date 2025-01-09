#---
# name: wyoming-whisper
# group: wyoming
# config: config.py
# depends: [homeassistant-base, cuda, cudnn, python:3.11, faster-whisper]
# test: test.sh
# requires: '>=34.1.0'
# docs: docs.md
# notes: The `faster-whisper` using the `wyoming` protocol for usage with Home Assistant. Based on `https://github.com/home-assistant/addons/blob/master/whisper/Dockerfile`
#---
ARG BASE_IMAGE=dustynv/jetson-inference:r32.7.1
FROM ${BASE_IMAGE}

ARG WYOMING_WHISPER_VERSION=2.2.0
ARG CTRANSLATE2_VERSION=v2.3.0

ENV PIP_BREAK_SYSTEM_PACKAGES=1 \
    WYOMING_WHISPER_VERSION="$WYOMING_WHISPER_VERSION" \
    HF_HUB_CACHE=/share/whisper \
    WHISPER_PORT=10300 \
    WHISPER_MODEL="tiny-int8" \
    WHISPER_BEAM_SIZE="1" \
    WHISPER_LANGUAGE="en" \
    WHISPER_DEBUG="true"

COPY rootfs/ /
COPY build.sh /tmp/wyoming/build_wyoming-faster-whisper.sh

WORKDIR /usr/src

RUN apt-get update && \
    add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-get install -y --no-install-recommends \
    gcc-8 g++-8 netcat \
    python3.8 python3.8-dev python3-pip \
    build-essential cmake git \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1 && \
    update-alternatives --set python3 /usr/bin/python3.8 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 80 --slave /usr/bin/g++ g++ /usr/bin/g++-8 && \
    update-alternatives --set gcc /usr/bin/gcc-8

RUN python3.8 -m pip install --no-cache-dir --upgrade -U \
    setuptools==58.0.0 \
    wheel \
    pip \
    packaging \
    pyparsing==2.4.7

RUN git clone -b ${CTRANSLATE2_VERSION} --recursive https://github.com/OpenNMT/CTranslate2.git
RUN cd CTranslate2 && \
    export CUDA_HOME=/usr/local/cuda && \
    export PATH=$CUDA_HOME/bin:$PATH && \
    export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH && \
    export LD_LIBRARY_PATH=/lib/aarch64-linux-gnu:$LD_LIBRARY_PATH && \
    export CPATH=:/usr/local/cuda/targets/aarch64-linux/include && \
    export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/cuda/targets/aarch64-linux/lib && \
    cmake -Bbuild_folder \
        -DWITH_MKL=OFF \
        -DOPENMP_RUNTIME=NONE \
        -DWITH_CUDA=ON \
        -DCMAKE_CXX_STANDARD=14 \
        -DCUDA_INCLUDE_DIRECTORIES=/usr/local/cuda/include \
        -DCUDA_CUBLAS_LIBRARIES=/usr/local/cuda/targets/aarch64-linux/lib/ \
        -DCUDA_INCLUDE_DIRECTORIES=/usr/local/cuda/include \
        -DCUDA_CUBLAS_LIBRARIES=/usr/local/cuda/targets/aarch64-linux/lib/libcublas.so \
        -DCUDA_cublas_LIBRARY=/usr/local/cuda/targets/aarch64-linux/lib/libcublas.so \
        -DCUDA_ARCH_LIST="5.3" \
        -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-10.2 \
        -DCMAKE_LIBRARY_PATH=/usr/local/cuda/targets/aarch64-linux/lib \
        && \
    cmake --build build_folder && \
    cd build_folder && \
    make install && \
    cd ../python && \
    pip3 install -r install_requirements.txt && \
    python3 setup.py bdist_wheel && \
    pip3 install dist/*.whl

RUN /tmp/wyoming/build_wyoming-faster-whisper.sh

EXPOSE ${WHISPER_PORT}/tcp

HEALTHCHECK --start-period=10m \
    CMD echo '{ "type": "describe" }' \
        | nc -w 1 localhost ${WHISPER_PORT} \
        | grep -q "faster-whisper" \
        || exit 1

CMD /init
