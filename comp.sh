#!/bin/bash

if [ ! -d "bin" ]; then
  mkdir -p bin
fi

while getopts ":s:h" option; do
  case $option in
    s)
      solver_name="$OPTARG"
      ;;
    h)
      echo "Usage: $0 [-s solver_name]"
      exit 1
      ;;
  esac
done
MAIN=""

if test -f "solvers/${solver_name}/${solver_name}.cu"; then

    # # COMPILE SRC CODE
    echo "COMPILING: src"
    for file in src/*.cu
    do
        filename=$(basename -- "$file")
        nvcc -c "$file" -O2 -o "bin/${filename%.cu}.o"
        echo "compiled $file to bin/${filename%.cu}.o"
    done

    ar rcs bin/libcupss.a bin/*.o
    echo "created static library bin/libcupss.a from object files"

    # # COMPILE SOLVER
    MAIN="solvers/${solver_name}/${solver_name}.cu"
    echo "COMPILING: ${MAIN}"
    nvcc ${MAIN} solvers/${solver_name}/parse_input.cpp -Lbin/ -lcufft -lfftw3f -lcurand -lcupss -O2 -o ./bin/$solver_name
else
    echo "Solver not found; Usage: $0 [-s solver_name]"
fi

