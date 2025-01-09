#---
# name: pyannote
# group: audio
# depends: [torchaudio, onnxruntime]
# requires: '>=32.*'
# test: test.py
#---
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN pip3 install --index-url https://pypi.org/simple uv

ENV SKLEARN_NO_OPENMP=1
RUN uv pip install --no-binary scikit-learn scikit-learn==1.3.2 --system

RUN uv pip install pyannote.audio==2.1.1 silero-vad --system

RUN echo "import torch; torch.__version__ = '1.13.0'" | tee /usr/local/lib/python3.8/dist-packages/sitecustomize.py

RUN pip3 show pyannote.audio && python3 -c 'import pyannote.audio; print(pyannote.audio.__version__)'
