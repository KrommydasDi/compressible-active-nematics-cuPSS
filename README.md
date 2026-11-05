# Compressible Active Nematics with cuPSS

CUDA-based simulations of compressible active nematics with uniform or spatially patterned activity, implemented using the cuPSS pseudospectral solver framework.

## Repository structure

- `src/` and `inc/`: cuPSS source code and headers.
- `solvers/Compressible_Active_Nematics/`: compressible active-nematic solver and default parameters.
- `run/`: simulation run script.
- `utils/`: Python scripts for generating movies from simulation output.
- `cluster/`: example SLURM submission script.
- `comp.sh`: compilation script.

## Upstream software

This repository builds on the [cuPSS](https://github.com/fcaballerop/cuPSS) pseudospectral solver framework developed by [Fernando Caballero](https://github.com/fcaballerop).

The repository structure and workflow were also informed by [Paarth Gulati](https://github.com/paarthgulati) and his [cuPSS-based code](https://github.com/paarthgulati/activeFolding_cuPSS).

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
./comp.sh -s Compressible_Active_Nematics
```

The executable is written to:

```text
bin/Compressible_Active_Nematics
```

## Running a simulation

Run the script from the repository root:

```bash
./run/run_Compressible_Active_Nematics.sh
```

Simulation outputs are written under:

```text
projects/Compressible_Active_Nematics/
```

The run script accepts command-line options for system size, activity, friction, density, diffusivity, elastic constant, timestep, saving interval, and other simulation parameters.

## Running on a SLURM cluster

Compile the solver first, then submit the example job script from the repository root:

```bash
sbatch cluster/Compressible_Active_Nematics.sbatch
```

The example script requests one GPU and writes standard output and error files to `logs/`.

The CUDA and Anaconda module names in `cluster/Compressible_Active_Nematics.sbatch` are cluster-specific and may need to be changed for another computing environment.

## Python utilities

Install the optional Python dependencies with:

```bash
python3 -m pip install -r requirements.txt
```

The scripts in `utils/` generate movies from the simulation output after a run is completed.

## License

This repository is distributed under the MIT License. See `LICENSE` for the retained upstream copyright notices and license terms.

## Citation

This solver is built using cuPSS. When using this code, please cite:

Fernando Caballero, “cuPSS: a package for pseudo-spectral integration of stochastic PDEs,” arXiv:2405.02410 [physics.comp-ph] (2024). https://doi.org/10.48550/arXiv.2405.02410
