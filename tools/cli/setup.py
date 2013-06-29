#!/usr/bin/env python

from setuptools import setup, find_packages
import os
import sys

VERSION="3.0.0"

install_requires = [
    "PyYAML >= 3.10",
    "Twisted >= 12.3.0",
]
if sys.version_info < (2, 7, 0):
    # argparse is already included with 2.7+
    install_requires.append("argparse >= 1.1")

data = []
for root, dirs, files in os.walk("src/flambe/data"):
    data += ["%s/%s" % (os.path.relpath(root, "src/flambe"), file) for file in files]

setup(name="flambe", version=VERSION,

    packages=find_packages("src"),
    package_dir={"": "src"},
    package_data={"flambe": data},
    scripts=["scripts/flambe"],
    zip_safe=False,
    install_requires=install_requires,

    author="Bruno Garcia",
    author_email="b@aduros.com",
    url="https://github.com/aduros/flambe",
)
