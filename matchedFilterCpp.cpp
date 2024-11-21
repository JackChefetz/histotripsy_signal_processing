#include "mex.h"
#include <vector>

// Function to perform convolution
std::vector<double> convolve(const std::vector<double>& signal, const std::vector<double>& filter) {
    int n = signal.size();
    int m = filter.size();
    int convSize = n; // For 'same' convolution

    std::vector<double> result(convSize, 0.0);

    for (int i = 0; i < convSize; ++i) {
        double sum = 0.0;
        for (int j = 0; j < m; ++j) {
            int k = i - m / 2 + j;
            if (k >= 0 && k < n) {
                sum += signal[k] * filter[m - j - 1]; // Flip filter
            }
        }
        result[i] = sum;
    }

    return result;
}

// MATLAB entry point
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    // Check for proper number of arguments
    if (nrhs != 2) {
        mexErrMsgIdAndTxt("MATLAB:matchedFilter:invalidNumInputs", "Two inputs required.");
    }
    if (nlhs != 1) {
        mexErrMsgIdAndTxt("MATLAB:matchedFilter:invalidNumOutputs", "One output required.");
    }

    // Get input data
    size_t signalSize = mxGetNumberOfElements(prhs[0]);
    double *signalData = mxGetPr(prhs[0]);
    std::vector<double> signal(signalData, signalData + signalSize);

    size_t filterSize = mxGetNumberOfElements(prhs[1]);
    double *filterData = mxGetPr(prhs[1]);
    std::vector<double> filter(filterData, filterData + filterSize);

    // Perform convolution
    std::vector<double> result = convolve(signal, filter);

    // Create output array
    plhs[0] = mxCreateDoubleMatrix(1, result.size(), mxREAL);
    double *outputData = mxGetPr(plhs[0]);
    std::copy(result.begin(), result.end(), outputData);
}
