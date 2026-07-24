import numpy as np
import matplotlib.pyplot as plt
import os
from matplotlib import animation
from matplotlib.animation import PillowWriter
import argparse
from tqdm import tqdm
import pandas as pd
import sys
from matplotlib.colors import TwoSlopeNorm

def main():
    inputArguments = parse_arguments()
    Nx = inputArguments.Nx
    Ny = inputArguments.Ny
    NSteps = inputArguments.NSteps
    NSave = inputArguments.NSave
    dt = inputArguments.dt
    center=inputArguments.center
    print('Saving movies:')

    fields_list = [item for item in inputArguments.list.split(',')]


    for s in  fields_list:
        X = load_data_file(s, int(NSteps-NSave), Nx, Ny)
        norm = TwoSlopeNorm(vmin=np.min(X), vcenter=center, vmax=np.max(X))
        ll=s
        if s == "phi":
            ll = r'$\phi(x,y)$'
        elif s =="Q2":
            ll = '$S^2(x,y)$'
        elif s =="v2":
            ll = '$v^2(x,y)$'
        elif s =="wxy":
            ll = r'$\Omega(x,y)$'
        elif s =="rho":
            ll = r'$\rho(x,y)$'
    
    #########################    
        
        X = load_data_file(s, 0, Nx, Ny)
        fig, ax = plt.subplots(1,1,figsize=(4,4))
        im = ax.imshow(X, cmap='PuOr_r', origin='lower', norm=norm)
        cb = fig.colorbar(im,ax=ax, label=ll, shrink=0.8)
        tx = ax.text(0,0,'t={:.1f}'.format(0.0), bbox=dict(boxstyle="round",ec='white',fc='white'))

        def animate(t):
            X = load_data_file(s, int(t*NSave), Nx, Ny)
            im.set_data(X)
            tx.set_text('t={:.1f}'.format(t*NSave*dt))
            return fig,

        ani = animation.FuncAnimation(fig, animate, frames= tqdm(range(NSteps//NSave-1), file=sys.stdout), interval = 1)
        writervideo = animation.FFMpegWriter(fps=10)
        ani.save('analysis/movies_quiv/'+s+'.mp4', writer=writervideo, dpi=300)
        print( s +' movie saved')




def load_data_file(s, N, Nx, Ny):
    filename = 'data/'+s+'.csv.' + str(N)
    x = pd.read_csv(filename, delimiter=',').values
    X = x[:, 2].reshape(Ny, Nx)

    return X


def parse_arguments():
    parser = argparse.ArgumentParser(description="pass parameters values along with their names to change the default parameter values")
    parser.add_argument('--Nx', type= int, default=128)
    parser.add_argument('--Ny', type= int, default=128)
    parser.add_argument('--NSteps', type= int, default=10000)
    parser.add_argument('--NSave', type= int, default=100)
    parser.add_argument('--dt', type= float, default=0.01)
    parser.add_argument('--center', type= float, default=1.0)

    parser.add_argument('-l', '--list', help='delimited list input', type=str)

    args = parser.parse_args()
    return args


if __name__=="__main__":
    main()