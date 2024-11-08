// credit to copilot

#include "mex.h"
#include <vector>
#include <cmath>
#include <chrono>
#include <iostream>

using namespace std;
using namespace std::chrono;

pair<double, double> powerLawFit(const vector<double>& x, const vector<double>& y) {
    int n = x.size();
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    vector<double> logX(n), logY(n);
    for (int i = 0; i < n; ++i) {
        logX[i] = log(x[i]);
        logY[i] = log(y[i]);
        sumX += logX[i];
        sumY += logY[i];
        sumXY += logX[i] * logY[i];
        sumX2 += logX[i] * logX[i];
    }

    double b = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    double logA = (sumY - b * sumX) / n;
    double a = exp(logA);

    return {a, b};
}

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {
    if (nrhs != 2) {
        mexErrMsgIdAndTxt("MyToolbox:powerFit:nrhs", "Two inputs required.");
    }
    if (nlhs != 1) {
        mexErrMsgIdAndTxt("MyToolbox:powerFit:nlhs", "One output required.");
    }

    double* xData = mxGetPr(prhs[0]);
    double* yData = mxGetPr(prhs[1]);
    mwSize n = mxGetM(prhs[0]);

    vector<double> x(xData, xData + n);
    vector<double> y(yData, yData + n);

    // start timing
    auto start = high_resolution_clock::now();

    pair<double, double> params = powerLawFit(x, y);

    // stop timing
    auto stop = high_resolution_clock::now();
    auto duration = duration_cast<microseconds>(stop - start);

    //output the duration using mexPrintf
    mexPrintf("Time taken by powerLawFit: %lld microseconds \n", duration.count());

    //output the format of the fitting function
    mexPrintf("Fitting function formal: y = %.4f * x^%4f\n", params.first, params.second);

    plhs[0] = mxCreateDoubleMatrix(1, 2, mxREAL);
    double* outData = mxGetPr(plhs[0]);

    outData[0] = params.first;
    outData[1] = params.second;
}
