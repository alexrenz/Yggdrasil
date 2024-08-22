using BinaryBuilder

name = "AWSCLI"
version = v"2.17.35"

sources = [
    GitSource("https://github.com/aws/aws-cli.git",
              "a55557d53742d03823bba42c42b3259a086ccf7f"),
]

script = raw"""
cd ${WORKSPACE}/srcdir/aws-cli

apk update
apk add python3-dev

export CMAKE_INSTALL_PREFIX="${prefix}"
export CMAKE_TOOLCHAIN_FILE="${CMAKE_TARGET_TOOLCHAIN}"

# Breaking change in Clang 16 causes failure while building dependencies on macOS and FreeBSD
# See https://discourse.llvm.org/t/clang-16-notice-of-potentially-breaking-changes/65562
CFLAGS="${CFLAGS} -Wno-error=incompatible-function-pointer-types"

PYTHON="$(which python3)" ./configure --prefix=${prefix} --with-download-deps --with-install-type=portable-exe
make -j${nproc}
make install

install_license ./LICENSE.txt
"""

platforms = supported_platforms()

products = [
    ExecutableProduct("aws", :awscli),
]

dependencies = [
    BuildDependency("Binutils_jll"),
]

build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies;
               compilers=[:c, :rust], preferred_gcc_version=v"5", julia_compat="1.6")
