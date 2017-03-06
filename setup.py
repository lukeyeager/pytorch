import os
import setuptools


with open ('README.txt', 'r') as infile:
    README = infile.read()


# If people try to actually install this package, throw an error
if os.getenv('PYTORCH_ALLOW_BUILD') is None:
    raise RuntimeError(README)


PKG_NAME = os.getenv('PYTORCH_PKG_NAME')
assert PKG_NAME in {'torch', 'pytorch'}


setuptools.setup(
    name=PKG_NAME,
    version='0.1.2.post1',
    description='Placeholder for PyTorch',
    url='http://pytorch.org/',
    include_package_data=True,
    zip_safe=False,
)
