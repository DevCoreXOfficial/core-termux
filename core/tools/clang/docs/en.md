## Package Information

- **Name:** Clang
- **Tags:** language, compiler, c, c++
- **Project:** https://clang.llvm.org
- **Source:** https://github.com/llvm/llvm-project
- **Dependencies:** None required by Core

## What is it?

The LLVM Project is a collection of modular and reusable compiler and toolchain technologies.

Full documentation: https://clang.llvm.org

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `clang`

### `--help` output

```text
OVERVIEW: clang LLVM compiler

USAGE: clang-21 [options] file...

OPTIONS:
  -###                    Print (but do not run) the commands to run for this compilation
  --analyzer-output <value>
                          Static analyzer report output format (html|plist|plist-multi-file|plist-html|sarif|sarif-html|text).
  --analyze               Run the static analyzer
  -B <prefix>             Search $prefix$file for executables, libraries, and data files. If $prefix is a directory, search $prefix/$file
  -b <arg>                Pass -b <arg> to the linker on AIX
  -CC                     Include comments from within macros in preprocessed output
  -cl-denorms-are-zero    OpenCL only. Allow denormals to be flushed to zero.
  -cl-ext=<value>         OpenCL only. Enable or disable OpenCL extensions/optional features. The argument is a comma-separated sequence of one or more extension names, each prefixed by '+' or '-'.
  -cl-fast-relaxed-math   OpenCL only. Sets -cl-finite-math-only and -cl-unsafe-math-optimizations, and defines __FAST_RELAXED_MATH__.
  -cl-finite-math-only    OpenCL only. Allow floating-point optimizations that assume arguments and results are not NaNs or +-Inf.
  -cl-fp32-correctly-rounded-divide-sqrt
                          OpenCL only. Specify that single precision floating-point divide and sqrt used in the program source are correctly rounded.
  -cl-kernel-arg-info     OpenCL only. Generate kernel argument metadata.
  -cl-mad-enable          OpenCL only. Allow use of less precise MAD computations in the generated binary.
  -cl-no-signed-zeros     OpenCL only. Allow use of less precise no signed zeros computations in the generated binary.
  -cl-no-stdinc           OpenCL only. Disables all standard includes containing non-native compiler types and functions.
  -cl-opt-disable         OpenCL only. This option disables all optimizations. By default optimizations are enabled.
  -cl-single-precision-constant
                          OpenCL only. Treat double precision floating-point constant as single precision constant.
  -cl-std=<value>         OpenCL language standard to compile for.
  -cl-strict-aliasing     OpenCL only. This option is added for compatibility with OpenCL 1.0.
  -cl-uniform-work-group-size
                          OpenCL only. Defines that the global work-size be a multiple of the work-group size specified to clEnqueueNDRangeKernel
  -cl-unsafe-math-optimizations
                          OpenCL only. Allow unsafe floating-point optimizations.  Also implies -cl-no-signed-zeros and -cl-mad-enable.
  -clangir-disable-passes Disable CIR transformations pipeline
  -clangir-disable-verifier
                          ClangIR: Disable MLIR module verifier
  --config=<file>         Specify configuration file
  --cuda-compile-host-device
                          Compile CUDA code for both host and device (default). Has no effect on non-CUDA compilations.
  --cuda-device-only      Compile CUDA code for device only
  --cuda-feature=<value>  Manually specify the CUDA feature to use
  --cuda-host-only        Compile CUDA code for host only. Has no effect on non-CUDA compilations.
  --cuda-include-ptx=<value>
                          Include PTX for the following GPU architecture (e.g. sm_35) or 'all'. May be specified more than once.
  --cuda-noopt-device-debug
                          Enable device-side debug info generation. Disables ptxas optimizations.
  --cuda-path-ignore-env  Ignore environment variables to detect CUDA installation
  --cuda-path=<value>     CUDA installation path
  -cuid=<value>           An ID for compilation unit, which should be the same for the same compilation unit but different for different compilation units. It is used to externalize device-side static variables for single source offloading languages CUDA and HIP so that they can be accessed by the host code of the same compilation unit.
  -cxx-isystem <directory>
                          Add directory to the C++ SYSTEM include search path
  -C                      Include comments in preprocessed output
  -c                      Only run preprocess, compile, and assemble steps
  -darwin-target-variant-triple <value>
                          Specify the darwin target variant triple
  -darwin-target-variant <value>
                          Generate code for an additional runtime variant of the deployment target
```

