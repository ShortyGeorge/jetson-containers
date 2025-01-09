#!/usr/bin/env bash
set -ex

if [ "$FORCE_BUILD" == "on" ]; then
	echo "Forcing build of torchvision ${TORCHVISION_VERSION}"
	exit 1
fi

if [ -n "$TORCHVISION_URL" ]; then
    # Download and install the torchvision wheel
    wget --quiet --show-progress --progress=bar:force:noscroll --no-check-certificate ${TORCHVISION_URL} -O /opt/${TORCHVISION_WHL}
    pip3 install --index-url https://pypi.org/simple /opt/${TORCHVISION_WHL}
else
    # Install from pip
    pip3 install --no-cache-dir torchvision~=${TORCHVISION_VERSION}
fi

# Verify installation
pip3 show torchvision && python3 -c 'import torchvision; print(torchvision.__version__);'

if [ $(lsb_release --codename --short) = "focal" ]; then
    # https://github.com/conda/conda/issues/13619
    pip3 install --no-cache-dir pyopenssl==24.0.0
fi
