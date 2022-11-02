import os
import py2app
import shutil

from distutils.core import setup

def tree(src):
    return [(root, map(lambda f: os.path.join(root, f), files))
        for (root, dirs, files) in os.walk(os.path.normpath(src))]

ENTRY_POINT = ['main.py']

DATA_FILES = tree('www')
OPTIONS = {
    'argv_emulation': False,
    'strip': True,
    'iconfile': 'assets/icon.icns',
    'includes': ['WebKit', 'Foundation', 'webview', 'pkg_resources.py2_warn']
}

setup(
    app=ENTRY_POINT,
    data_files=DATA_FILES,
    options={'py2app': OPTIONS},
    setup_requires=['py2app'],
)