#!/usr/bin/env python

# Copyright (C) 2016-2018 SignalFx, Inc. All rights reserved.

from setuptools import setup, find_packages

with open('signalflowcli/version.py') as f:
    exec(f.read())

#with open('README.rst') as readme:
    #long_description = readme.read()

with open('requirements.txt') as f:
    requirements = [line.strip() for line in f.readlines()]

setup(
    name=name,  # noqa
    version=version,  # noqa
    author='SignalFx, Inc',
    author_email='info@signalfx.com',
    description='SignalFx Python Library',
    license='Apache Software License v2',
    #long_description=long_description,
    zip_safe=True,
    packages=find_packages(),
    install_requires=requirements,
    classifiers=[
        'Operating System :: OS Independent',
        'Programming Language :: Python',
    ],
    entry_points={
        'console_scripts': [
            'signalflow=signalflowcli.prompt:main',
            'csv-to-plot=signalflowcli.graph:main',
        ],
    },
    #url='https://github.com/signalfx/signalflow-cli',
)
