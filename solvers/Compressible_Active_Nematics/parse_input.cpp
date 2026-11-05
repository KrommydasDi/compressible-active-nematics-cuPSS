
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>
#include "parse_input.h"

system_parameters parser(char* paramsFile){ 
  
  FILE* fparams = fopen(paramsFile, "r");
  if (fparams == NULL) {
    printf("ERROR: cannot open the parameter file!\n");
    exit (EXIT_FAILURE);
  }

  char line [1000];

  system_parameters sys_par;

  int nparams = 0;

  while (fgets(line, sizeof(line), fparams) != NULL) {
    nparams += sscanf(line, "Nx = %d", &sys_par.Nx);    
    nparams += sscanf(line, "Ny = %d", &sys_par.Ny);    
    nparams += sscanf(line, "NSteps = %d", &sys_par.NSteps);    
    nparams += sscanf(line, "NSave = %d", &sys_par.NSave);    
    nparams += sscanf(line, "dx = %f", &sys_par.dx);
    nparams += sscanf(line, "dy = %f", &sys_par.dy);
    nparams += sscanf(line, "dt = %f", &sys_par.dt);
    nparams += sscanf(line, "D = %f", &sys_par.D);   
    nparams += sscanf(line, "eta = %f", &sys_par.eta);   
    nparams += sscanf(line, "friction = %f", &sys_par.friction);   
    nparams += sscanf(line, "r = %f", &sys_par.r);   
    nparams += sscanf(line, "u = %f", &sys_par.u);   
    nparams += sscanf(line, "K = %f", &sys_par.K);   
    nparams += sscanf(line, "lambda = %f", &sys_par.lambda);   
    nparams += sscanf(line, "alpha = %f", &sys_par.alpha);   
    nparams += sscanf(line, "alphaB = %f", &sys_par.alphaB);   
    nparams += sscanf(line, "seed = %d", &sys_par.seed);   
    nparams += sscanf(line, "chi = %f", &sys_par.chi);   
    nparams += sscanf(line, "rhoc = %f", &sys_par.rhoc);   
    nparams += sscanf(line, "meanrho = %f", &sys_par.meanrho);   
    nparams += sscanf(line, "patternCode = %d", &sys_par.patternCode);   
  }

  fclose(fparams);

  printf("Read parameters:\n");
  printf("Nx = %d; ", sys_par.Nx);
  printf("Ny = %d; ", sys_par.Ny);
  printf("NSteps = %d; ", sys_par.NSteps);
  printf("NSave = %d; \n", sys_par.NSave);
  printf("dx = %.1f; ", sys_par.dx);
  printf("dy = %.1f; ", sys_par.dy);
  printf("dt = %.5f; ", sys_par.dt);
  printf("D = %.5f; ", sys_par.D);
  printf("eta = %.2f; ", sys_par.eta);
  printf("friction = %.2f; ", sys_par.friction);
  printf("r = %.2f; ", sys_par.r);
  printf("u = %.2f; ", sys_par.u);
  printf("K = %.2f; ", sys_par.K);
  printf("lambda = %.2f; ", sys_par.lambda);
  printf("alpha = %.2f; ", sys_par.alpha);
  printf("alphaB = %.2f; ", sys_par.alphaB);
  printf("seed = %d; ", sys_par.seed);
  printf("chi = %.2f; ", sys_par.chi);
  printf("rhoc = %.2f; ", sys_par.rhoc);
  printf("meanrho = %.2f; ", sys_par.meanrho);
  printf("patternCode = %d; ", sys_par.patternCode);


  if (nparams != 21) {
    printf("ERROR: Incorrect number of parameters! \n");
    exit (EXIT_FAILURE);
  }  

  return sys_par; 
}