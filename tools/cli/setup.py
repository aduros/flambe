#!/usr/bin/env python

from setuptools import setup, find_packages
import os

VERSION="3.0.0"

data = []
for root, dirs, files in os.walk("src/flambe/data"):
    data += ["%s/%s" % (os.path.relpath(root, "src/flambe"), file) for file in files]

setup(name="flambe", version=VERSION,

    packages=find_packages("src"),
    package_dir={"": "src"},
    package_data={"flambe": data},
    scripts=["scripts/flambe"],
    zip_safe=False,

    author="Bruno Garcia",
    author_email="b@aduros.com",
    url="https://github.com/aduros/flambe",
)
