import sys
import os

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

# Usage: python setup.py build_ext --i

version = '0.01'

include_path =['cython/include/']

# Platform-dependent submodules

if sys.platform == 'win32':
    # MS Windows
    libs = ['glew32', 'glu32', 'glfw', 'opengl32']
elif sys.platform == 'darwin': 
    # Apple OSX
    raise SystemError('OSX is unsupported in this version')
else:
    # GNU/Linux, BSD, etc
    libs = ['GLEW', 'GLU', 'glfw', 'GL']
    
mod_engine = Extension(
    "engine",
    ["cython/src/game_engine.pyx"], 
    libraries = libs,
    language = 'c'
)

setup(
    name = 'OpenMelee',
    version = version,
    description = 'A Star Control Clone',
    author = 'Mason Green & Tom Novelli',
    author_email = '',
    maintainer = '',
    maintainer_email = '',
    url = 'http://openmelee.org/',
    cmdclass = {'build_ext': build_ext},
    ext_modules = [mod_engine],
    include_dirs = [os.path.abspath(p) for p in include_path]
)