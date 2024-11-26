#!/usr/bin/env bash
set -ex

# Clone the repository if it doesn't exist
git clone --branch=v${SANA_VERSION} --depth=1 --recursive https://github.com/NVlabs/Sana /opt/sana || \
git clone --depth=1 --recursive https://github.com/NVlabs/Sana /opt/sana

# Navigate to the directory containing sana's setup.py
cd /opt/sana 
pip install -U pip
pip install -e .

export MAX_JOBS=$(nproc)
pip3 wheel --no-build-isolation --wheel-dir=/opt/sana/wheels .
pip3 install --no-cache-dir --verbose /opt/sana/wheels/sana*.whl

cd /opt/sana
pip3 install 'numpy<2'

# Optionally upload to a repository using Twine
twine upload --verbose /opt/sana/wheels/sana*.whl || echo "Failed to upload wheel to ${TWINE_REPOSITORY_URL}"
