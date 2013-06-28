#!/usr/bin/env python

from setuptools import setup, find_packages

VERSION="3.0.0"

setup(name="flambe", version=VERSION,

    packages=find_packages("src"),
    package_dir={"": "src"},
    package_data = {"flambe": ["data/*"]},
    scripts=["scripts/flambe"],
    zip_safe=False,

    author="Bruno Garcia",
    author_email="b@aduros.com",
    url="https://github.com/aduros/flambe",
)
