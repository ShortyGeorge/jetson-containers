from jetson_containers import update_dependencies
from packaging.version import Version
from ..pytorch.version import PYTORCH_VERSION


def torchvision(version, pytorch=None, requires=None):
    pkg = package.copy()

    pkg['name'] = f"torchvision:{version.split('-')[0]}"

    if pytorch:
        pkg['depends'] = update_dependencies(
            pkg['depends'], f"pytorch:{pytorch}")
    else:
        pytorch = PYTORCH_VERSION

    if requires:
        pkg['requires'] = requires

    if len(version.split('.')) < 3:
        version = version + '.0'

    pkg['build_args'] = {
        'TORCHVISION_VERSION': version,
    }

    builder = pkg.copy()
    builder['name'] = builder['name'] + '-builder'
    builder['build_args'] = {**builder['build_args'], 'FORCE_BUILD': 'on'}

    if not isinstance(pytorch, Version):
        pytorch = Version(pytorch)

    if pytorch == PYTORCH_VERSION:
        pkg['alias'] = 'torchvision'
        builder['alias'] = 'torchvision:builder'

    return pkg, builder


def torchvision_wget(version, whl, url, pytorch=None, requires=None):
    pkg, builder = torchvision(version, pytorch, requires)

    pkg['build_args']['TORCHVISION_WHL'] = whl
    pkg['build_args']['TORCHVISION_URL'] = url

    return pkg, builder


package = [
    # JetPack 5/6
    torchvision('0.15.1', pytorch='2.0', requires='==35.*'),
    torchvision('0.16.2', pytorch='2.1', requires='>=35'),
    torchvision('0.17.2', pytorch='2.2', requires='>=35'),
    torchvision('0.18.0', pytorch='2.3', requires='==36.*'),
    torchvision('0.19.1', pytorch='2.4', requires='==36.*'),
    torchvision('0.20.0', pytorch='2.5', requires='==36.*'),
    torchvision('0.21.0', pytorch='2.6', requires='==36.*'),
    #torchvision('0.17.2', pytorch='2.2', requires='==36.*'),
    #torchvision('0.18.0-rc1', pytorch='2.3', requires='==36.*'),
    # JetPack 4
    torchvision_wget(
        '0.14.0',
        whl='torchvision-0.14.0a0+5ce4506-cp38-cp38-linux_aarch64.whl',
        url='https://github.com/ShortyGeorge/jetson-nano-ml/releases/download/torchvision-v0.14.0/torchvision-0.14.0a0+5ce4506-cp38-cp38-linux_aarch64.whl',
        pytorch='1.13',
        requires='==32.*'
    ),
    torchvision('0.11.1', pytorch='1.10', requires='==32.*'),
    torchvision('0.10.0', pytorch='1.9', requires='==32.*'),
]
