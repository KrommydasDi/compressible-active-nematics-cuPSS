#!/bin/bash
#
#SBATCH -J actPat_p
#SBATCH -p gpu
#SBATCH --gres=gpu:1
#SBATCH -N 1
#SBATCH --ntasks-per-node=6
#SBATCH -t 48:00:00
#SBATCH -o logs/actPat_p_%j.out
#SBATCH -e logs/actPat_p_%j.err

module purge
module load cuda/12.4
module load anaconda/3.13

export CUDA_HOME=/sw/cuda/cuda-12.4
export PATH="$CUDA_HOME/bin:$PATH"
export LD_LIBRARY_PATH="$CUDA_HOME/lib64:$LD_LIBRARY_PATH"
export CPATH="$CUDA_HOME/include:$CPATH"
export LIBRARY_PATH="$CUDA_HOME/lib64:$LIBRARY_PATH"

# Ensure logs dir exists in the workdir
mkdir -p logs

echo "========================================"
echo "Job ID: $SLURM_JOB_ID"
echo "Nodes:  $SLURM_JOB_NODELIST"
echo "Start : $(date)"
echo "CWD   : $(pwd)"
echo "========================================"

./run/run_Compressible_Active_Nematics.sh

echo "========================================"
echo "End   : $(date)"
echo "========================================"
