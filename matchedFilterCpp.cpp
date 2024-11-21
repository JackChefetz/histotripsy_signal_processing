#include "mex.h"
#include <vector>
#include <immintrin.h> // Header for SIMD intrinsics

// Inline function to perform convolution using SIMD
inline std::vector<double> convolve(const std::vector<double>& signal, const std::vector<double>& filter) {
    int n = signal.size();
    int m = filter.size();
    int convSize = n; // For 'same' convolution

    std::vector<double> result(convSize, 0.0);

    for (int i = 0; i < convSize; ++i) {
        __m256d sum = _mm256_setzero_pd(); // Initialize sum to zero

        int j = 0;
        for (; j <= m - 4; j += 4) {
            int k0 = i - m / 2 + j;
            int k1 = k0 + 1;
            int k2 = k0 + 2;
            int k3 = k0 + 3;

            __m256d signal_vec = _mm256_set_pd(
                k3 >= 0 && k3 < n ? signal[k3] : 0.0,
                k2 >= 0 && k2 < n ? signal[k2] : 0.0,
                k1 >= 0 && k1 < n ? signal[k1] : 0.0,
                k0 >= 0 && k0 < n ? signal[k0] : 0.0
            );

            __m256d filter_vec = _mm256_set_pd(
                filter[m - j - 1],
                filter[m - j - 2],
                filter[m - j - 3],
                filter[m - j - 4]
            );

            sum = _mm256_add_pd(sum, _mm256_mul_pd(signal_vec, filter_vec));
        }

        double sum_array[4];
        _mm256_storeu_pd(sum_array, sum);
        result[i] = sum_array[0] + sum_array[1] + sum_array[2] + sum_array[3];

        // Handle remaining elements
        for (; j < m; ++j) {
            int k = i - m / 2 + j;
            if (k >= 0 && k < n) {
                result[i] += signal[k] * filter[m - j - 1];
            }
        }
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
