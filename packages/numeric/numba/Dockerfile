#---
# name: numba
# group: cuda
# depends: [cuda, numpy]
# test: test.py
#---
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
            llvm-9 \
            llvm-9-dev \
            clang-9 \
            libffi-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# https://github.com/numba/llvmlite/issues/621#issuecomment-737100914
# Update alternatives for llvm-config and clang
RUN update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-9 100 && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-9 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-9 100

RUN pip3 install --index-url https://pypi.org/simple --no-cache-dir "pip==20.3.4" "setuptools==58.5.*"

# Install llvmlite 0.35.0 from source
RUN git clone https://github.com/numba/llvmlite.git && \
    cd llvmlite && \
    git checkout tags/v0.35.0 && \
    LLVM_CONFIG=/usr/bin/llvm-config python3 setup.py install && \
    cd .. && \
    rm -rf llvmlite

RUN python3 -c 'import llvmlite; print("llvmlite version:", llvmlite.__version__)'

# Install Numba 0.52.0 from source
RUN git clone https://github.com/numba/numba.git && \
    cd numba && \
    git checkout tags/0.52.0 && \
    python3 setup.py install && \
    cd .. && \
    rm -rf numba

RUN pip3 show numba && python3 -c 'import numba; print(numba.__version__)'
