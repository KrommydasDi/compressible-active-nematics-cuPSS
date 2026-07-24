struct system_parameters
{
    float dx, dy, dt, D, eta, friction;
    int Nx, Ny, NSteps, NSave, seed;
    float r, u, K, lambda, alpha, chi, alphaB;
    float rhoc, meanrho;
    int patternCode;
};

system_parameters parser(char* paramsFile);