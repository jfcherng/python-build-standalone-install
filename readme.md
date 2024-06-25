## Introduction

Downloads and installs a standalone Python build from [indygreg/python-build-standalone][].

## Usage

1. Run `install.sh`.
2. Under the installed directory, there will be a `source.bash` file.
   Source it in your `.bashrc` or `.bash_profile` file.
3. Test the Python installation by running `python -VV`.

## Customization

You can set the following environment variables:

- `URL_PYTHON_TARBALL`: URL to the Python tarball to download. E.g., `https://github.com/indygreg/python-build-standalone/releases/download/20240415/cpython-3.12.3+20240415-x86_64-unknown-linux-gnu-install_only.tar.gz`
- `PYTHON_INSTALL_DIR`: Directory to install Python. E.g., `/home/jfcherng/opt/python3.12`

## Tarball Naming Explanation

See https://gregoryszorc.com/docs/python-build-standalone/stable/running.html

The minimum glibc version required for most targets is 2.17.

- `x86_64-unknown-linux-gnu`: Linux 64-bit Intel/AMD CPUs linking against glibc. Maximum portability.
- `x86_64_v2-*`: Targets 64-bit Intel/AMD CPUs approximately newer than Nehalem (released in 2008). Binaries will have SSE3, SSE4, and other CPU instructions added after the ~initial x86-64 CPUs were launched in 2003.
- `x86_64_v3-*`: Targets 64-bit Intel/AMD CPUs approximately newer than Haswell (released in 2013) and Excavator (released in 2015). Binaries will have AVX, AVX2, MOVBE and other newer CPU instructions.
- `x86_64_v4-*`: (Unrecommended) Targets 64-bit Intel/AMD CPUs with some AVX-512 instructions. Requires Intel CPUs manufactured after ~2017. But many Intel CPUs don't have AVX-512.

<!-- references -->

[indygreg/python-build-standalone]: https://github.com/indygreg/python-build-standalone
