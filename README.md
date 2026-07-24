# Compressible Active Nematics with cuPSS

CUDA-based simulations of compressible active nematics with uniform or spatially patterned activity, implemented using the cuPSS pseudospectral solver framework.

## Repository structure

- `src/` and `inc/`: cuPSS source code and headers.
- `solvers/compressibleFlow_final_final/`: compressible active-nematic solver and default parameters.
- `run/`: simulation run script.
- `utils/`: Python scripts for generating movies from simulation output.
- `cluster/`: example SLURM submission script.
- `comp.sh`: compilation script.

## Upstream software

This repository builds on the [cuPSS](https://github.com/fcaballerop/cuPSS) pseudospectral solver framework developed by Fernando Caballero.

The repository structure and workflow were also informed by [Paarth Gulati's cuPSS-based code](https://github.com/paarthgulati/activeFolding_cuPSS).

The original copyright notices are retained in the `LICENSE` file.

## Requirements

The simulation code requires:

- NVIDIA CUDA Toolkit with `nvcc`
- cuFFT
- cuRAND
- FFTW3 single-precision library (`fftw3f`)
- A CUDA-capable NVIDIA GPU

The optional movie-generation scripts require Python 3 and the packages listed in `requirements.txt`.

## Compilation

From the repository root, compile the compressible active-nematic solver with:

```bash
./comp.sh -s compressibleFlow_final_final
```

The executable is written to:

```text
bin/compressibleFlow_final_final
```

## Running a simulation

Run the script from the repository root:

```bash
./run/run_compressible_final_final.sh
```

Simulation outputs are written under:

```text
projects/activePatterning_final_final/
```

The run script accepts command-line options for system size, activity, friction, density, diffusivity, elastic constant, timestep, saving interval, and other simulation parameters.

## Running on a SLURM cluster

Compile the solver first, then submit the example job script from the repository root:

```bash
sbatch cluster/actPat_p.sbatch
```

The example script requests one GPU and writes standard output and error files to `logs/`.

The CUDA and Anaconda module names in `cluster/actPat_p.sbatch` are cluster-specific and may need to be changed for another computing environment.

## Python utilities

Install the optional Python dependencies with:

```bash
python3 -m pip install -r requirements.txt
```

The scripts in `utils/` generate movies from the simulation output after a run is completed.

## License

This repository is distributed under the MIT License. See `LICENSE` for the retained upstream copyright notices and license terms.
