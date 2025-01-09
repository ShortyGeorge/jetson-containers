#---
# name: torchaudio
# group: pytorch
# config: config.py
# depends: [pytorch, cmake]
# test: test.py
#---
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG TORCHAUDIO_VERSION \
    FORCE_BUILD=off

COPY install.sh build.sh /tmp/torchaudio/

ENV LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libgomp.so.1
ENV STACK_SIZE=65536

RUN ulimit -s 65536 && \
    /tmp/torchaudio/install.sh || /tmp/torchaudio/build.sh
