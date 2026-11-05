#!/bin/bash
projectName="Compressible_Active_Nematics"
solver_name="Compressible_Active_Nematics"

rootDir=$(pwd)
log_message="Solver used: ${solver_name}"

Nx=512
Ny=512

NSteps=500000
NSave=5000
dt=0.001
seed=1

friction=0.0001

alpha=-1.0
alphaB=-0.7

r=0.2
K=0.2
chi=0.7
D=1.0

rhoc=1.0
meanrho=0.7

dx=1.0
dy=1.0

patternCode=11

eta=1.0

while getopts ":a:f:e:s:d:c:m:D:N:n:t:L:K:p:h" option; do
  case $option in
    a)
      alpha=$OPTARG
      ;;
    f)
      friction=$OPTARG
      ;;
    e)
      eta=$OPTARG
      ;;
    s)
      seed=$OPTARG
      ;;
    d)
      dx=$OPTARG
      dy=$OPTARG
      ;;
    c)
      chi=$OPTARG
      ;;
    m)
      meanrho=$OPTARG
      ;;
    D)
      D=$OPTARG
      ;;
    N)
      NSteps=$OPTARG
      ;;
    n)
      NSave=$OPTARG
      ;;
    t)
      dt=$OPTARG
      ;;
    L)
      Nx=$OPTARG
      Ny=$OPTARG
      ;;
    K)
      K=$OPTARG
      ;;
    p)
      patternCode=$OPTARG
      ;;
    h)
      echo "Usage: $0"
      exit 1
      ;;
  esac
done

# DIRTREE=frictional_${friction}/pattern_${patternCode}/Nx_${Nx}_Ny_${Ny}_NSteps_${NSteps}_dt_${dt}_dx_${dx}_dy_${dy}/D_${D}_K_${K}_r_${r}/rhoc_${rhoc}_meanrho_${meanrho}/chi_${chi}_alpha_${alpha}_alphaB_${alphaB}_seed_${seed}
DIRTREE=pattern_${patternCode}/frictional_${friction}/eta_${eta}/Nx_${Nx}_Ny_${Ny}_NSteps_${NSteps}_NSave_${NSave}_dt_${dt}_dx_${dx}_dy_${dy}/D_${D}_K_${K}_r_${r}/rhoc_${rhoc}_meanrho_${meanrho}/chi_${chi}_alpha_${alpha}_alphaB_${alphaB}_seed_${seed}
####################################################
PROJECTDIR=projects/$projectName

echo "Using solver ${solver_name}."
echo "Working in $PROJECTDIR"

#CHECK FOR PROPER PROJECT INITIALIZATION
if [ ! -d "$PROJECTDIR" ]; then
 echo "$PROJECTDIR does not exist. Initializing the project directory."
 mkdir -p $PROJECTDIR
fi


if [ ! -d "$PROJECTDIR/$DIRTREE" ]; then
 echo "Initializing $PROJECTDIR/$DIRTREE"
 mkdir -p $PROJECTDIR/$DIRTREE
else
 echo "$PROJECTDIR/$DIRTREE already exists! \n \n \nOVERWRITING! \n \n \nYou have 2 seconds to cancel"
 sleep 2s
 rm -rf $PROJECTDIR/$DIRTREE
 mkdir $PROJECTDIR/$DIRTREE
fi

cp solvers/${solver_name}/default_parameters.txt $PROJECTDIR/$DIRTREE/sim_parameters.txt 
mkdir $PROJECTDIR/$DIRTREE/data

cd $PROJECTDIR/$DIRTREE

sed -i 's/^Nx .*$/Nx = '${Nx}'/' sim_parameters.txt
sed -i 's/^Ny .*$/Ny = '${Ny}'/' sim_parameters.txt
sed -i 's/^NSteps .*$/NSteps = '${NSteps}'/' sim_parameters.txt
sed -i 's/^NSave .*$/NSave = '${NSave}'/' sim_parameters.txt
sed -i 's/^dt .*$/dt = '${dt}'/' sim_parameters.txt
sed -i 's/^D .*$/D = '${D}'/' sim_parameters.txt

sed -i 's/^alpha .*$/alpha = '${alpha}'/' sim_parameters.txt
sed -i 's/^alphaB .*$/alphaB = '${alphaB}'/' sim_parameters.txt
sed -i 's/^r .*$/r = '${r}'/' sim_parameters.txt
sed -i 's/^K .*$/K = '${K}'/' sim_parameters.txt
sed -i 's/^seed .*$/seed = '${seed}'/' sim_parameters.txt
sed -i 's/^chi .*$/chi = '${chi}'/' sim_parameters.txt

sed -i 's/^friction .*$/friction = '${friction}'/' sim_parameters.txt

sed -i 's/^dx .*$/dx = '${dx}'/' sim_parameters.txt
sed -i 's/^dy .*$/dy = '${dy}'/' sim_parameters.txt

sed -i 's/^rhoc .*$/rhoc = '${rhoc}'/' sim_parameters.txt
sed -i 's/^meanrho .*$/meanrho = '${meanrho}'/' sim_parameters.txt
sed -i 's/^eta .*$/eta = '${eta}'/' sim_parameters.txt

sed -i 's/^patternCode .*$/patternCode = '${patternCode}'/' sim_parameters.txt

echo "Simulation Initialized! Running."
printf "Solver used: ${solver_name} \n \n" >> logf.txt

exec > >(tee -a logf.txt) 2>&1

${rootDir}/bin/${solver_name} sim_parameters.txt


echo "Simulation Finished! Creating avi files."
if [ ! -d "analysis/movies" ]; then
 mkdir -p analysis/movies
fi

python3 ${rootDir}/utils/movie_2dfunc_red.py --Nx ${Nx} --Ny ${Ny} --NSteps ${NSteps} --NSave ${NSave} --dt ${dt} -l "rho"
python3 ${rootDir}/utils/movie_2dfunc_red.py --Nx ${Nx} --Ny ${Ny} --NSteps ${NSteps} --NSave ${NSave} --dt ${dt} -l "intensity"
python3 ${rootDir}/utils/movie_2dfunc_RdBu.py --Nx ${Nx} --Ny ${Ny} --NSteps ${NSteps} --NSave ${NSave} --dt ${dt} -l "wxy"
python3 ${rootDir}/utils/movie_2dfunc_red.py --Nx ${Nx} --Ny ${Ny} --NSteps ${NSteps} --NSave ${NSave} --dt ${dt} -l "TrQ2"

##################################################### Only remake video
# PROJECTDIR=projects/$projectName
# cd $PROJECTDIR/$DIRTREE

# if [ ! -d "analysis/movies_quiv" ]; then
#   echo "analysis/movies_quiv does not exist. Initializing the directory."
#   mkdir -p analysis/movies_quiv
# fi

# python3 ${rootDir}/utils/movie_2dfunc_RdBu_2Slope.py --Nx ${Nx} --Ny ${Ny} --NSteps ${NSteps} --NSave ${NSave} --dt ${dt} --center ${meanrho} -l "rho"

# python ${rootDir}/utils/movie_2dfunc_red.py --Nx ${Nx} --Ny ${Ny} --NSteps ${NSteps} --NSave ${NSave} --dt ${dt} -l "rho"
# python3 ${rootDir}/utils/movie_2dfunc_RdBu.py --Nx ${Nx} --Ny ${Ny} --NSteps ${NSteps} --NSave ${NSave} --dt ${dt} -l "wxy"
# python ${rootDir}/utils/movie_2dfunc_red.py --Nx ${Nx} --Ny ${Ny} --NSteps ${NSteps} --NSave ${NSave} --dt ${dt} -l "TrQ2"
# python3 ${rootDir}/utils/movie_2dfunc_RdBu.py --Nx ${Nx} --Ny ${Ny} --NSteps ${NSteps} --NSave ${NSave} --dt ${dt} -l "v2"