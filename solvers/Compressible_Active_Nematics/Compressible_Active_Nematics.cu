#include <iostream>
#include "../../inc/cupss.h"
#include <cuda.h>
#include <cuda_runtime.h>
#include "parse_input.h"
#include <cmath>  // for sin/tanh, roundf

// Also traceless correction for Qxx

void constIntensity(evolver *, float2 *, int, int, int);
__global__ void const_k(float2 *intensity, int sx, int sy, int sz);

void sineIntensity(evolver *, float2 *, int, int, int);
__global__ void sine_k(float2 *intensity, int sx, int sy, int sz);

void tanhIntensity(evolver *, float2 *, int, int, int);
__global__ void tanh_k(float2 *intensity, int sx, int sy, int sz);

void sine2Intensity(evolver *, float2 *, int, int, int);
__global__ void sine2_k(float2 *intensity, int sx, int sy, int sz);

void sine4Intensity(evolver *, float2 *, int, int, int);
__global__ void sine4_k(float2 *intensity, int sx, int sy, int sz);

void sine8Intensity(evolver *, float2 *, int, int, int);
__global__ void sine8_k(float2 *intensity, int sx, int sy, int sz);

void sine16Intensity(evolver *, float2 *, int, int, int);
__global__ void sine16_k(float2 *intensity, int sx, int sy, int sz);

void sine32Intensity(evolver *, float2 *, int, int, int);
__global__ void sine32_k(float2 *intensity, int sx, int sy, int sz);

// NEW: L/64, L/128, and ~L=180 (periodic)
void sine64Intensity(evolver *, float2 *, int, int, int);
__global__ void sine64_k(float2 *intensity, int sx, int sy, int sz);

void sine128Intensity(evolver *, float2 *, int, int, int);
__global__ void sine128_k(float2 *intensity, int sx, int sy, int sz);

int main(int argc, char **argv)
{
    if (argc < 2) 
    {
        printf("Usage: model param_file level\n");
        return 1;
    }

    system_parameters sys_par= parser(argv[1]);

    // The 1 is the GPU flag
    evolver system(1, sys_par.Nx, sys_par.Ny, sys_par.dx, sys_par.dy, sys_par.dt, sys_par.NSave); 

    system.createField("rho", true);
    system.createField("iqxrho", false);
    system.createField("iqyrho", false);

    // symmetric traceless, 2 components
    system.createField("Qxx", true);
    system.createField("Qxy", true);

    system.createField("iqxQxx", false);
    system.createField("iqyQxx", false);
    system.createField("iqxQxy", false);
    system.createField("iqyQxy", false);
    system.createField("q2Qxx", false);
    system.createField("q2Qxy", false);
    
    // symmetric traceless, 2 components
    system.createField("sigxx", false);
    system.createField("sigxy", false);

    // 2 component flow velocity
    system.createField("vx", false);
    system.createField("vy", false);

    // Flow derivatives
    system.createField("iqxvx", false);
    system.createField("iqyvx", false);
    system.createField("iqxvy", false);
    system.createField("iqyvy", false);
    system.createField("wxy", false);

    system.createField("v2", false);
    system.createField("intensity", false);
    system.createField("pressure", false);
    system.createField("TrQ2", false);
    system.createField("divV", false);

    // Fixing the rho drift 
    system.createField("rhoVx", false);
    system.createField("rhoVy", false);
    system.createField("iqxrhoVx", false);
    system.createField("iqyrhoVy", false);

    // Fixing high friction
    system.createField("drho", false);


    // free energy parameters
    system.addParameter("D", sys_par.D);
    system.addParameter("r", sys_par.r);
    system.addParameter("u", sys_par.u);
    system.addParameter("K", sys_par.K);

    system.addParameter("friction", sys_par.friction);

    switch (sys_par.patternCode)
    {
    case 0: // constant intensity
        system.fieldsMap["intensity"]->hasCB = true;
        system.fieldsMap["intensity"]->callback = constIntensity;
        break;

    case 10: // sine, λ = L/1
        system.fieldsMap["intensity"]->hasCB = true;
        system.fieldsMap["intensity"]->callback = sineIntensity;
        break;

    case 11: // sine, λ = L/2
        system.fieldsMap["intensity"]->hasCB = true;
        system.fieldsMap["intensity"]->callback = sine2Intensity;
        break;

    case 12: // sine, λ = L/4
        system.fieldsMap["intensity"]->hasCB = true;
        system.fieldsMap["intensity"]->callback = sine4Intensity;
        break;

    case 13: // sine, λ = L/8
        system.fieldsMap["intensity"]->hasCB = true;
        system.fieldsMap["intensity"]->callback = sine8Intensity;
        break;

    case 14: // sine, λ = L/16
        system.fieldsMap["intensity"]->hasCB = true;
        system.fieldsMap["intensity"]->callback = sine16Intensity;
        break;

    case 15: // sine, λ = L/32
        system.fieldsMap["intensity"]->hasCB = true;
        system.fieldsMap["intensity"]->callback = sine32Intensity;
        break;

    case 16: // NEW: sine, λ = L/64
        system.fieldsMap["intensity"]->hasCB = true;
        system.fieldsMap["intensity"]->callback = sine64Intensity;
        break;

    case 17: // NEW: sine, λ = L/128
        system.fieldsMap["intensity"]->hasCB = true;
        system.fieldsMap["intensity"]->callback = sine128Intensity;
        break;

    case 20: // tanh intensity
        system.fieldsMap["intensity"]->hasCB = true;
        system.fieldsMap["intensity"]->callback = tanhIntensity;
        break;

    default:
        system.fieldsMap["intensity"]->hasCB = true;
        system.fieldsMap["intensity"]->callback = constIntensity;
    }

    // flow parameters
    system.addParameter("eta", sys_par.eta);
    system.addParameter("lambda", sys_par.lambda);
    system.addParameter("alpha", sys_par.alpha);
    system.addParameter("chi", sys_par.chi);
    system.addParameter("rhoc", sys_par.rhoc);
    system.addParameter("meanrho", sys_par.meanrho);
    system.addParameter("alphaB", sys_par.alphaB);

    // Works -- Density in friction
    // system.addEquation("vx * (eta*q^2) =  (iqx*sigxx + iqy*sigxy) - iqx * pressure - vx * friction * rho ");
    // system.addEquation("vy * (eta*q^2) =  (iqx*sigxy - iqy*sigxx) - iqy * pressure - vy * friction * rho ");
    
    // Fixing high friction
    system.addEquation("drho = rho - meanrho");

    system.addEquation("vx * eta * q^2 + vx * friction * meanrho = (iqx*sigxx + iqy*sigxy) - iqx * pressure - vx * friction * drho");
    system.addEquation("vy * eta * q^2 + vy * friction * meanrho = (iqx*sigxy - iqy*sigxx) - iqy * pressure - vy * friction * drho");

    // What I have used so far! 
    // system.addEquation("dt rho + q^2 * D * rho = - vx*iqxrho - vy*iqyrho  - rho * iqxvx - rho * iqyvy");
    

    // New rho block fixing drift
    system.addEquation("rhoVx = rho * vx");
    system.addEquation("rhoVy = rho * vy");

    system.addEquation("iqxrhoVx = iqx * rhoVx");
    system.addEquation("iqyrhoVy = iqy * rhoVy");

    system.addEquation("dt rho + q^2 * D * rho = - iqxrhoVx - iqyrhoVy");

    // Conserved
    system.addEquation("dt Qxx = - r * Qxx * (1 - (1/rhoc) * rho) - K * q2Qxx -u * TrQ2 * Qxx * rho * (1/rhoc) - vx*iqxQxx - vy*iqyQxx + (lambda * (1/2)) * (iqxvx - iqyvy) - iqxvy * Qxy + iqyvx * Qxy");
    system.addEquation("dt Qxy = - r * Qxy * (1 - (1/rhoc) * rho) - K * q2Qxy -u * TrQ2 * Qxy * rho * (1/rhoc) - vx*iqxQxy - vy*iqyQxy + (lambda * (1/2)) * (iqxvy + iqyvx) + iqxvy * Qxx - iqyvx * Qxx");    

    // Non-conserved Old
    // system.addEquation("dt Qxx = - r * Qxx * (1 - (1/rhoc) * rho) - K * q2Qxx -u * TrQ2 * Qxx * rho * (1/rhoc) - vx*iqxQxx - vy*iqyQxx - Qxx*iqxvx - Qxx*iqyvy + (lambda * (1/2)) * (iqxvx - iqyvy) - iqxvy * Qxy + iqyvx * Qxy");
    // system.addEquation("dt Qxy = - r * Qxy * (1 - (1/rhoc) * rho) - K * q2Qxy -u * TrQ2 * Qxy * rho * (1/rhoc) - vx*iqxQxy - vy*iqyQxy - Qxy*iqxvx - Qxy*iqyvy + (lambda * (1/2)) * (iqxvy + iqyvx) + iqxvy * Qxx - iqyvx * Qxx");

    system.addEquation("TrQ2 = Qxx*Qxx + Qxy*Qxy");
    system.addEquation("pressure = chi*rho - alphaB * rho * (1/rhoc) * intensity");

    system.addEquation("wxy =  (1/2)*(iqx*vy - iqy*vx)");
    system.addEquation("v2 =  vx * vx + vy * vy");
    system.addEquation("divV =  iqx * vx + iqy * vy");

    system.addEquation("iqxrho = iqx*rho");
    system.addEquation("iqyrho = iqy*rho");

    system.addEquation("iqxQxx = iqx*Qxx");
    system.addEquation("iqyQxx = iqy*Qxx");
    system.addEquation("iqxQxy = iqx*Qxy");
    system.addEquation("iqyQxy = iqy*Qxy");
    system.addEquation("q2Qxx = q^2 * Qxx");
    system.addEquation("q2Qxy = q^2 * Qxy");

    system.addEquation("iqxvx =  iqx*vx");
    system.addEquation("iqyvx =  iqy*vx");
    system.addEquation("iqxvy =  iqx*vy");
    system.addEquation("iqyvy =  iqy*vy");

    system.addEquation("sigxx = alpha * rho * (1/rhoc)*intensity*Qxx");
    system.addEquation("sigxy = alpha * rho * (1/rhoc)*intensity*Qxy");

    std::srand(sys_par.seed);

    // system.initializeUniformNoise("Qxx", 0.00, 1.00);
    system.initializeUniformNoise("Qxx", 0.05f, 0.0f);
    system.initializeUniformNoise("Qxy", 0.05f, 0.0f);
    system.initializeUniformNoise("rho", 0.05, sys_par.meanrho);
    system.initializeUniformNoise("pressure", 0.0, 0.0);
    // system.initializePatternSinusoid("intensity", 1);

    system.prepareProblem();    
    system.setOutputField("rho", true);
    system.setOutputField("TrQ2", true);
    system.setOutputField("Qxx", true);
    system.setOutputField("Qxy", true);
    system.setOutputField("vx", true);
    system.setOutputField("vy", true);
    system.setOutputField("divV", true);
    system.setOutputField("v2", true);
    system.setOutputField("wxy", true);
    system.setOutputField("intensity", true);
    // system.setOutputField("pressure", true);

    int steps = sys_par.NSteps;
    int check = steps/100;
    if (check < 1) check = 1;

    // system.printInformation();

    for (int i = 0; i < steps; i++)
    {
        system.advanceTime();
        if (i % check == 0)
        {
            std::cout << "Progress: " << i/check << "%\r";
            std::cout.flush();
        }
    }
 
    return 0;
}

// ==================== Intensity callbacks & kernels ====================

void constIntensity(evolver *sys, float2 *intensity, int sx, int sy, int sz)
{
    const_k<<<sys->blocks, sys->threads_per_block>>>(intensity, sx, sy, sz);
}

__global__ void const_k(float2 *intensity, int sx, int sy, int sz)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;

    if (i < sx && j < sy)
    {
        int index = j * sx + i;
        intensity[index].x = 1.0f;
        intensity[index].y = 0.0f;
    }
}

void sineIntensity(evolver *sys, float2 *intensity, int sx, int sy, int sz)
{
    sine_k<<<sys->blocks, sys->threads_per_block>>>(intensity, sx, sy, sz);
}
__global__ void sine_k(float2 *intensity, int sx, int sy, int sz)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;

    if (i < sx && j < sy)
    {
        int index = j * sx + i;
        intensity[index].x = (1+std::sin(2*3.14159f*i/sx))/2.0f;
        intensity[index].y = 0.0f;
    }
}

void tanhIntensity(evolver *sys, float2 *intensity, int sx, int sy, int sz)
{
    tanh_k<<<sys->blocks, sys->threads_per_block>>>(intensity, sx, sy, sz);
}
__global__ void tanh_k(float2 *intensity, int sx, int sy, int sz)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;

    if (i < sx && j < sy)
    {
        int index = j * sx + i;
        intensity[index].x = (1+std::tanh((sx/2.0f - i)/2.0f))/2.0f;
        intensity[index].y = 0.0f;
    }
}

void sine2Intensity(evolver *sys, float2 *intensity, int sx, int sy, int sz)
{
    sine2_k<<<sys->blocks, sys->threads_per_block>>>(intensity, sx, sy, sz);
}
__global__ void sine2_k(float2 *intensity, int sx, int sy, int sz)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;

    if (i < sx && j < sy)
    {
        int index = j * sx + i;
        intensity[index].x = (1+std::sin(2*2*3.14159f*i/sx))/2.0f;
        intensity[index].y = 0.0f;
    }
}

void sine4Intensity(evolver *sys, float2 *intensity, int sx, int sy, int sz)
{
    sine4_k<<<sys->blocks, sys->threads_per_block>>>(intensity, sx, sy, sz);
}
__global__ void sine4_k(float2 *intensity, int sx, int sy, int sz)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;

    if (i < sx && j < sy)
    {
        int index = j * sx + i;
        intensity[index].x = (1+std::sin(2*4*3.14159f*i/sx))/2.0f;
        intensity[index].y = 0.0f;
    }
}

void sine8Intensity(evolver *sys, float2 *intensity, int sx, int sy, int sz)
{
    sine8_k<<<sys->blocks, sys->threads_per_block>>>(intensity, sx, sy, sz);
}
__global__ void sine8_k(float2 *intensity, int sx, int sy, int sz)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;

    if (i < sx && j < sy)
    {
        int index = j * sx + i;
        intensity[index].x = (1+std::sin(2*8*3.14159f*i/sx))/2.0f;
        intensity[index].y = 0.0f;
    }
}

void sine16Intensity(evolver *sys, float2 *intensity, int sx, int sy, int sz)
{
    sine16_k<<<sys->blocks, sys->threads_per_block>>>(intensity, sx, sy, sz);
}
__global__ void sine16_k(float2 *intensity, int sx, int sy, int sz)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;

    if (i < sx && j < sy)
    {
        int index = j * sx + i;
        intensity[index].x = (1+std::sin(2*16*3.14159f*i/sx))/2.0f;
        intensity[index].y = 0.0f;
    }
}

void sine32Intensity(evolver *sys, float2 *intensity, int sx, int sy, int sz)
{
    sine32_k<<<sys->blocks, sys->threads_per_block>>>(intensity, sx, sy, sz);
}
__global__ void sine32_k(float2 *intensity, int sx, int sy, int sz)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;

    if (i < sx && j < sy)
    {
        int index = j * sx + i;
        intensity[index].x = (1+std::sin(2*32*3.14159f*i/sx))/2.0f;
        intensity[index].y = 0.0f;
    }
}

// ============ NEW patterns ============

void sine64Intensity(evolver *sys, float2 *intensity, int sx, int sy, int sz)
{
    sine64_k<<<sys->blocks, sys->threads_per_block>>>(intensity, sx, sy, sz);
}
__global__ void sine64_k(float2 *intensity, int sx, int sy, int sz)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;
    
    if (i < sx && j < sy)
    {
        int index = j * sx + i;
        intensity[index].x = (1 + std::sin(2 * 64.0f * 3.14159f * i / sx)) / 2.0f;
        intensity[index].y = 0.0f;
    }
}

void sine128Intensity(evolver *sys, float2 *intensity, int sx, int sy, int sz)
{
    sine128_k<<<sys->blocks, sys->threads_per_block>>>(intensity, sx, sy, sz);
}
__global__ void sine128_k(float2 *intensity, int sx, int sy, int sz)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;
    
    if (i < sx && j < sy)
    {
        int index = j * sx + i;
        intensity[index].x = (1 + std::sin(2 * 128.0f * 3.14159f * i / sx)) / 2.0f;
        intensity[index].y = 0.0f;
    }
}