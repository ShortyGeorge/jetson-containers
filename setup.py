from setuptools import setup, find_packages

setup(
    name='jetson_containers',
    version='0.1',
    packages=find_packages(),
    install_requires=[
        # List your project's dependencies here.
    ],
    entry_points={
        'console_scripts': [
            'autotag=jetson_containers.tag:main',
        ],
    },
    classifiers=[
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
    ],
    python_requires='>=3.6',
)

